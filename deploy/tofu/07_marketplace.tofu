resource "opennebula_marketplace" "federation-marketplace" {
  name = "federation-marketplace"

  s3 {
    type = "ceph"
    access_key_id = ""
    secret_access_key = ""
    region = "marketplace"
    endpoint_url = "http://192.168.10.95"
    bucket_id= ""
  }
}
