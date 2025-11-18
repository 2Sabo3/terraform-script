variable "name" {
    type = string
    default = "promtail"
}
variable "namespace" {
    type = string
    default = "monitoring"
}
variable "chart_version" {
    type = string
    default = "6.17.1"
}

