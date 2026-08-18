# Managed Device

Gebruik deze map voor Intune-upload naar managed macOS devices.

## Bestanden

| Bestand | Gebruik |
| --- | --- |
| `com.github.macadmins.Nudge.pilot.mobileconfig` | Nudge configuratieprofiel voor de macOS update pilot |
| `com.github.macadmins.Nudge.notifications.mobileconfig` | Notification profiel waarmee Nudge meldingen mag tonen |
| `install-nudge-logo-itq.zsh` | Optioneel Intune shell script om het ITQ-logo lokaal te downloaden |

## Intune

Maak twee aparte macOS Custom configuration profiles:

1. Upload `com.github.macadmins.Nudge.pilot.mobileconfig`.
2. Upload `com.github.macadmins.Nudge.notifications.mobileconfig`.

Assign beide profielen alleen aan de Nudge pilotgroep.

De Nudge-config gebruikt standaard de HTTPS-logo URL direct. Het script `install-nudge-logo-itq.zsh` is daarom alleen nodig als je later bewust naar een lokaal logo-pad wilt overstappen.

Maak alleen dan een macOS shell script in Intune voor `install-nudge-logo-itq.zsh`:

- Run script as signed-in user: `No`
- Hide script notifications on devices: `Yes`
- Script frequency: `Not configured` / once
- Max retries: `3`

Het script schrijft het logo naar:

```text
/Library/Application Support/ITQ/Nudge/nudge-logo-itq.png
```
