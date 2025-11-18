variable "name" {
    type = string
    default = "loki"
}
variable "namespace" {
    type = string
    default = "monitoring"
}
variable "chart_version" {
    type = string
    default = "6.46.0"
}

