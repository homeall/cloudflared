# docker-bake.hcl
# Centralized Docker Build configuration

# Set variable for labeling image
variable "CLOUDFLARED_VERSION" {
  default = "2025.5.0"
}

group "default" {
  targets = ["build"]
}

target "docker-metadata-action" {}

target "build" {
  inherits   = ["docker-metadata-action"]
  context    = "."
  dockerfile = "Dockerfile"

  # Multi-platform build
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/arm",
  ]

  # GitHub Actions cache
  cache-from = [
    "type=gha"
  ]
  cache-to = [
    "type=gha,mode=max"
  ]

  # Image labels
  labels = {
    "cloudflared.version" = "${CLOUDFLARED_VERSION}"
    "maintainer"           = "Homeall"
    "homeall.buymeacoffee" = "☕ Like this project? Buy me a coffee: https://www.buymeacoffee.com/homeall 😎"
    "homeall.easteregg"    = "🎉 You found the hidden label! Have a nice day. 😎"
  }
  # Image annotation
  annotations = [
    "cloudflared.version=${CLOUDFLARED_VERSION}"
  ]
  # Build arguments
  args = {
    "CLOUDFLARED_VERSION" = "2025.5.0"
  }

  # Build attestations: SBOM and provenance (max detail)
  attest = [
    {
      type = "provenance"
      mode = "max"
    },
    {
      type = "sbom"
    }
  ]
}