# effective-goggles

Effective Goggles is a (very simple) iOS app that allows event hosts to track participants for certain events.

This is designed to work with the [HackIllinois API](https://github.com/HackIllinois/api-2017). This is the current flow:

- An API admin sets up a Universally Tracked event (within the iOS app) that has a name and a duration. Currently, the UI checks the role in the JWT token that the API returns to determine if the logged in user can access the "new event" page.
- The API will begin tracking that event, and only allows each user to "participate" once. "Participation" is defined as a POST to the `/v1/tracking/:id` endpoint, where `id` is the user ID embedded in the QR code.
- Effective Goggles allows hosts to scan user's QR codes and the app will indicate if it is their first time participating in the currently tracked event.

Build/usage instructions TBD.

