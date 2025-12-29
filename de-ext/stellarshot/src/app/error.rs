use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Rustic error: {0}")]
    Rustic(#[from] rustic_core::RusticError),
    #[error("Anyhow error: {0}")]
    Anyhow(#[from] anyhow::Error),
}
