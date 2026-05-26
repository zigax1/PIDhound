cask "pidhound" do
  version "1.0.0"
  sha256 "REPLACE_WITH_DMG_SHA256"

  url "https://github.com/zigax1/PIDhound/releases/download/v#{version}/PIDhound-#{version}.dmg"
  name "PIDhound"
  desc "Sniffs out the AI processes you forgot about"
  homepage "https://github.com/zigax1/PIDhound"

  depends_on macos: ">= :sonoma"
  depends_on arch: :arm64

  app "PIDhound.app"

  zap trash: [
    "~/Library/Application Support/PIDhound",
  ]
end
