use super::response_converter::ResponseConverter;
use async_stream::try_stream;
use http::header::HeaderName;
use http::uri::Uri;
use hyper::body::HttpBody;
use hyper::client::HttpConnector;
use hyper::Client;
use hyper::{Body, Request, Response};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;

pub struct ProxyService {
    upstream_base_uri: Uri,
    upstream_http_client: Client<HttpConnector>,
    total_request_count: AtomicU64,
    total_successful_request_count: AtomicU64,
    no_chunked: bool,
}

impl ProxyService {
    pub fn new(upstream_base_uri: Uri, no_chunked: bool) -> ProxyService {
        let mut http_connector = HttpConnector::new();
        // https://github.com/golang/go/blob/go1.14.1/src/net/tcpsock.go#L195
        http_connector.set_nodelay(true);
        // https://github.com/golang/go/blob/go1.14.1/src/net/dial.go#L15-L19
        http_connector.set_keepalive(Some(Duration::from_secs(15)));

        let http_client = Client::builder()
            //.http1_writev(false)
            // https://github.com/golang/go/blob/go1.14.1/src/net/http/httputil/reverseproxy.go#L412
            //.http1_read_buf_exact_size(32 * 1024)
            //.http1_max_buf_size(1024 * 1024)
            .build(http_connector);
        ProxyService {
            upstream_base_uri,
            upstream_http_client: http_client,
            total_request_count: AtomicU64::new(0),
            total_successful_request_count: AtomicU64::new(0),
            no_chunked,
        }
    }

    pub async fn handler(
        self: Arc<Self>,
        request: Request<Body>,
    ) -> Result<Response<Body>, Box<dyn std::error::Error + Send + Sync>> {
        self.total_request_count.fetch_add(1, Ordering::SeqCst);

        let mut uri_parts = self.upstream_base_uri.clone().into_parts();
        uri_parts.path_and_query = request.uri().path_and_query().cloned();
        let upstream_uri = Uri::from_parts(uri_parts)?;
        //println!("{}", upstream_uri);
        let mut upstream_request_builder = Request::get(upstream_uri);
        for (key, value) in request.headers() {
            if !is_hop_by_hop_header(key) {
                upstream_request_builder = upstream_request_builder.header(key, value);
            }
        }
        let mut upstream_response = self
            .upstream_http_client
            .request(upstream_request_builder.body(Body::empty())?)
            .await?;

        let mut response_builder = Response::builder().status(upstream_response.status());

        for (key, value) in upstream_response.headers() {
            if !is_hop_by_hop_header(key) && (self.no_chunked || key != "content-length") {
                response_builder = response_builder.header(key, value);
            }
        }

        let response_body_stream: async_stream::AsyncStream<Result<_, hyper::Error>, _> = try_stream! {
            let mut response_converter = ResponseConverter::new();
            while let Some(chunk) = upstream_response.body_mut().data().await {
                let output = response_converter.convert(chunk?)?;
                yield output;
            }
            let output = response_converter.finish()?;
            yield output;
            self.total_successful_request_count.fetch_add(1, Ordering::SeqCst);
        };
        Ok(response_builder.body(Body::wrap_stream(response_body_stream))?)
    }

    pub fn print_stat(&self) {
        print!(
            "total_request_count={}\ntotal_successful_request_count={}\n",
            self.total_request_count.load(Ordering::SeqCst),
            self.total_successful_request_count.load(Ordering::SeqCst),
        );
    }
}

// https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13.5.1
fn is_hop_by_hop_header(header_name: &HeaderName) -> bool {
    let hop_by_hop_headers = &[
        "connection",
        "keep-alive",
        "proxy-authenticate",
        "proxy-authorization",
        "te",
        "trailers",
        "transfer-encoding",
        "upgrade",
    ];
    hop_by_hop_headers.contains(&header_name.as_str())
}
