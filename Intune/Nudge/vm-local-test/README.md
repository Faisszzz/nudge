# VM Local Test

Gebruik deze map alleen voor lokaal testen op een VM of test-Mac zonder Intune-profile upload.

## Bestand

| Bestand | Gebruik |
| --- | --- |
| `com.github.macadmins.Nudge.pilot.json` | Leesbare Nudge pilotconfig voor lokaal testen |

## Lokaal Testen

Nudge leest standaard een JSON-config uit:

```text
/Library/Preferences/com.github.macadmins.Nudge.json
```

Plaats de JSON daar op een test-VM wanneer je Nudge lokaal wilt starten. Dit test alleen de Nudge app, SOFA-resolutie, UI en logging. Het test geen Intune assignment, DDM enforcement of notification profile delivery.
