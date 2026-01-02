resource "opennebula_marketplace" "federation-marketplace" {
  name = "federation-marketplace"

  s3 {
    type = "ceph"
    access_key_id = "xxxxxxxxxxxxx"
    secret_access_key = "xxxxxxxxxxxxx"
    region = "marketplace"
    endpoint_url = "http://192.168.10.254"
    bucket_id= "xxxxxxxxxxxxx"
  }
}
