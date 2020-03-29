use hyper::service::{make_service_fn, service_fn};
use hyper::Server;
use proxy_service::ProxyService;
use std::net::SocketAddr;
use std::sync::Arc;
use structopt::StructOpt;

mod proxy_service;
mod response_converter;

#[derive(Debug, StructOpt)]
#[structopt()]
struct Opt {
    #[structopt(long, default_value = "3001")]
    port: u16,

    #[structopt(long, default_value = "127.0.0.1:1888")]
    upstream_addr: String,

    #[structopt(long)]
    no_chunked: bool,
}

//#[cfg(not(target_env = "msvc"))]
//#[global_allocator]
//static GLOBAL: jemallocator::Jemalloc = jemallocator::Jemalloc;

async fn shutdown_signal() {
    tokio::signal::ctrl_c()
        .await
        .expect("failed to install CTRL+C signal handler");
}

async fn async_main() -> Result<(), Box<dyn std::error::Error>> {
    let opt = Opt::from_args();
    println!("{:?}", opt);

    let addr = SocketAddr::from(([127, 0, 0, 1], opt.port));
    let upstream_base_uri_str = format!("http://{}", opt.upstream_addr);
    let upstream_base_uri = upstream_base_uri_str.parse().expect("failed to parse uri");

    let proxy_service = Arc::new(ProxyService::new(upstream_base_uri, opt.no_chunked));
    let inner_proxy_service = proxy_service.clone();
    let make_proxy_service = make_service_fn(move |_addr_stream| {
        let inner_inner_proxy_service = inner_proxy_service.clone();
        async {
            Ok::<_, Box<dyn std::error::Error + Send + Sync>>(service_fn(move |request| {
                inner_inner_proxy_service.clone().handler(request)
            }))
        }
    });

    let server = Server::bind(&addr)
        //.http1_max_buf_size(1024 * 1024)
        .tcp_nodelay(true)
        .tcp_keepalive(Some(std::time::Duration::from_secs(15)))
        .serve(make_proxy_service)
        .with_graceful_shutdown(shutdown_signal());
    if let Err(e) = server.await {
        eprintln!("server error: {}", e);
    }

    proxy_service.print_stat();
    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut rt = tokio::runtime::Builder::new()
        .threaded_scheduler()
        .enable_all()
        //.core_threads(16)
        //.max_threads(10000)
        .build()?;
    rt.block_on(async_main())
}
