# Managed Device

Gebruik deze map voor Intune-upload naar managed macOS devices.

## Bestanden

| Bestand | Gebruik |
| --- | --- |
| `com.github.macadmins.Nudge.pilot.mobileconfig` | Nudge configuratieprofiel voor de macOS update pilot |
| `com.github.macadmins.Nudge.notifications.mobileconfig` | Notification profiel waarmee Nudge meldingen mag tonen |

## Intune

Maak twee aparte macOS Custom configuration profiles:

1. Upload `com.github.macadmins.Nudge.pilot.mobileconfig`.
2. Upload `com.github.macadmins.Nudge.notifications.mobileconfig`.

Assign beide profielen alleen aan de Nudge pilotgroep.
