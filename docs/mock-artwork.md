# Mock event artwork

Asset: `CocoaHeadsNetworking/Sources/CocoaHeadsNetworking/Resources/community-hero.png`.
This is a fictional meetup photograph for local sample data, not a photo of a real chapter event.
Some fixtures use it as `imageURL`; others deliberately omit artwork to exercise the fallback.

Generation mode: built-in image generation, new image, no reference image. Saved as a bundled
PNG; no image postprocessing. The synthetic fixture URL maps directly to this package resource
in Mock mode and never produces an HTTP request.

Prompt:

> Use case: photorealistic-natural. Asset type: bundled mock hero photograph for the CocoaHeads Brasil native app, landscape 1536x1024. Primary request: tasteful editorial image of a small welcoming Brazilian developer meetup. Foreground has an open aluminum laptop (screen contains subtle abstract code-like shapes, no readable text), a ceramic coffee cup, and a notebook on a warm wood communal table; a few casually dressed adult people collaborate softly out of focus in the upper background, green plants and gentle emerald ambient accents. Natural late-afternoon window light, real textures, calm and approachable, premium restrained photography. Wide composition allowing a dark lower gradient and app title to be overlaid later, key laptop and people readable in a wide banner crop. No logos, no readable words, no watermark, no frames, no UI mockup. This is a fictional illustrative scene for local sample data.
