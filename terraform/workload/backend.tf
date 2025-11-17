terraform {
  backend "gcs" {
    bucket = "tfstate-test-kose01"
    prefix = "state"
  }
}
