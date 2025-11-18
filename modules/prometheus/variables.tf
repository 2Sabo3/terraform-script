variable "name" {
    type = string
    default = "prometheus"
}
variable "namespace" {
    type = string
    default = "monitoring"
}
variable "chart_version" {
    type = string
    default = "79.5.0"
}
