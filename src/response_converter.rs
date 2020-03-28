use hyper::body::Bytes;

pub struct ResponseConverter {}

impl ResponseConverter {
    pub fn new() -> ResponseConverter {
        ResponseConverter {}
    }

    pub fn convert(&mut self, bytes: Bytes) -> Result<Bytes, hyper::Error> {
        Ok(bytes)
    }

    pub fn finish(self) -> Result<Bytes, hyper::Error> {
        Ok(Bytes::new())
    }
}
