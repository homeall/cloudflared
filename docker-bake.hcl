# --------------------------------------------------------------------
# docker-bake.hcl
# Centralized Docker Build configuration for multi-platform and CI/CD
# --------------------------------------------------------------------

# Set variable for labeling image
variable "CLOUDFLARED_VERSION" {
  default = "2025.5.0"
}

# Default build group
group "default" {
  targets = ["build"]
}

# Target for Docker metadata action (populated by workflow)
target "docker-metadata-action" {}

# Main build target
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

  # ---------- Image Labels ----------
  labels = {
    "cloudflared.version"  = "${CLOUDFLARED_VERSION}"
    "maintainer"           = "Homeall"
    "homeall.buymeacoffee" = "☕ Like this project? Buy me a coffee: https://www.buymeacoffee.com/homeall 😎"
    "homeall.easteregg"    = "🎉 You found the hidden label! Have a nice day. 😎"
  }

  # ---------- Image Annotations (OCI manifest-level) ----------
  annotations = [
    "cloudflared.version=${CLOUDFLARED_VERSION}",
    "maintainer=Image lovingly brewed by Homeall ☕",
    "homeall.buymeacoffee=Want to caffeinate my coding? Visit: https://www.buymeacoffee.com/homeall 🚀",
    "homeall.easteregg=Did you know? Inspecting images for hidden messages is a sign of true curiosity! 👀"
  ]

  # ----- Build arguments --------------
  args = {
    "CLOUDFLARED_VERSION" = "2025.5.0"
  }

 # ---------- Build Attestations ----------
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
