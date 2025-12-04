require "prometheus/api_client"

$PROMETHEUS_SERVER = "http://192.168.10.30:9090"

def load_metrics
  prometheus = Prometheus::ApiClient.client(url: PROMETHEUS_SERVER)
  metrics = {
    host_cpu: "opennebula_host_cpu_usage_ratio",
    ds_total: "opennebula_datastore_total_bytes",
    ds_free: "opennebula_datastore_free_bytes",
  }
  query_metric = Proc.new { |name, metric| [name, prometheus.query(query: metric)[:result].first[:value][1]] }
  metrics.map(&query_metric)
end
