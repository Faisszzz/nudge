# ITQ Nudge Pilot voor Intune macOS Updates

Dit document beschrijft hoe Nudge wordt ingezet naast de bestaande Intune macOS update- en compliance policies. Het doel is om Nudge eerst als pilot te testen op een kleine groep managed Macs, zonder de bestaande Intune/DDM enforcement te vervangen.

## Doel

Nudge wordt gebruikt als communicatie- en begeleidingslaag richting de gebruiker. Intune/DDM blijft verantwoordelijk voor het technische updatebeleid, zoals downloaden, installeren en afdwingen van macOS updates.

Kort gezegd:

- Intune/DDM is de enforcement-laag.
- Nudge is de gebruiker-communicatie en reminder-laag.
- Compliance bepaalt wanneer een device niet meer voldoet aan minimale toegangseisen.

## Huidige Intune Context

Uit de Inforcer-export `ITQ-EUC-lab-Documentation.html` zijn deze macOS policies relevant. Deze export staat in dezelfde map als dit document.

### macOS Software Update Policy

Policy:

`DCP-ITQ-da-all-mac-Updates-Software-Update`

Belangrijke instellingen:

- `Enforce Latest Software Update Version`: `True`
- `Delay In Days`: `3`
- `Install Time`: `12:30`
- `Allow Standard User OS Updates`: `Allowed`
- `Download`: `AlwaysOn`
- `Install OS Updates`: `Always On`
- `Install Security Update`: `AlwaysOn`
- `Notifications`: `Enabled`

Deze policy zorgt ervoor dat Macs naar de nieuwste beschikbare software update bewegen. De update wordt na 3 dagen afgedwongen, met installatietijd om 12:30.

### macOS Compliance Policy

Policy:

`DRP-da-all-Mac-Device-OS`

Belangrijke instellingen:

- `OS Minimum Version`: `15.0`
- `Grace Period Hours`: `12`
- `Action Type`: `block`

Deze policy bewaakt alleen de minimale macOS-versie voor compliance. Een Mac op macOS 15.0 of hoger voldoet aan deze policy, ook als er nieuwere minor updates beschikbaar zijn.

### App Store en Software Update UX

Relevant gedrag:

- `Disable Software Update Notifications`: moet `True` worden voor de Nudge pilot
- `Restrict Store Software Update Only`: `True`

Voor de Nudge pilot moet de standaard macOS/System Settings software update notificatie worden uitgeschakeld. Nudge neemt de gebruikercommunicatie over, zodat de gebruiker niet twee verschillende update-reminders naast elkaar krijgt.

De technische updateflow blijft ongewijzigd:

- Intune/DDM blijft updates downloaden, installeren en afdwingen.
- Nudge toont de updatecommunicatie.
- System Settings mag nog steeds gebruikt worden om de update te starten, maar is niet meer de primaire notificatielaag.

## Waarom Nudge Niet Op Compliance 15.0 Wordt Gebaseerd

De compliance policy zegt alleen: een Mac moet minimaal macOS 15.0 draaien.

Voorbeelden:

- macOS 14.x: niet compliant
- macOS 15.0: compliant
- macOS 15.1: compliant
- macOS 15.6.1: compliant

Maar de update policy verwacht meer dan dat. Die policy dwingt de nieuwste beschikbare update af na 3 dagen. Daarom moet Nudge aansluiten op de update policy, niet alleen op `OS Minimum Version = 15.0`.

Daarom gebruikt de pilot:

```json
"requiredMinimumOSVersion": "latest-supported"
```

Hiermee volgt Nudge de SOFA-feed en bepaalt het de nieuwste ondersteunde macOS-versie voor het device.

## Gekozen Nudge Rol

Voor deze pilot neemt Nudge geen harde acties over van Intune. De pilotconfig gebruikt bewust veilige instellingen:

```json
"attemptToBlockApplicationLaunches": false,
"terminateApplicationsOnLaunch": false,
"aggressiveUserExperience": false,
"aggressiveUserFullScreenExperience": false
```

Reden:

- Geen applicaties blokkeren tijdens de eerste pilot.
- Geen applicaties afsluiten tijdens de eerste pilot.
- Wel duidelijke communicatie richting gebruiker op dag 1 en dag 2.
- Geen aggressive mode, omdat Intune op dag 3 al de enforcement uitvoert.
- Intune/DDM blijft de echte update enforcement uitvoeren.

## Pilotbestanden

De bestanden zijn gesplitst per gebruiksscenario:

| Bestand | Doel |
| --- | --- |
| `managed-device/com.github.macadmins.Nudge.pilot.mobileconfig` | Uploadbaar Intune Custom profile voor managed Macs |
| `managed-device/com.github.macadmins.Nudge.notifications.mobileconfig` | Uploadbaar Intune Custom profile voor Nudge meldingen op managed Macs |
| `vm-local-test/com.github.macadmins.Nudge.pilot.json` | Leesbare JSON-versie voor lokaal testen op een VM |

Gebruik voor Intune alleen de bestanden in `managed-device/`. Gebruik `vm-local-test/` alleen wanneer je Nudge lokaal of op een losse VM wilt starten zonder Intune-profielupload.

## Actuele UI-Variant

De managed-device en VM-local-test configuraties gebruiken dezelfde vriendelijke pilottekst:

```text
Your Mac has an update waiting
A friendly heads-up from ITQ
Pick a good moment to update
Update Now
Remind Me
```

De linker statuskolom toont wel `Required OS Version`, `Current OS Version`, `Days Remaining To Update` en `Deferred Count`, maar geen aparte required-date regel.

## Aanbevolen Intune Structuur

Maak Nudge los van de bestaande baseline aan. Voeg Nudge niet direct toe aan een algemene security baseline.

Aanbevolen policy-namen:

- `DCP-ITQ-da-all-mac-Updates-Nudge-Pilot`
- `DCP-ITQ-da-all-mac-Notifications-Nudge-Pilot`
- `APP-ITQ-da-all-mac-Nudge-Pilot`

Reden:

- Nudge kan apart getest en teruggedraaid worden.
- De bestaande macOS update policy blijft leidend.
- De pilotgroep kan klein blijven.
- Troubleshooting wordt eenvoudiger.

## Stap 1: Nudge App Installeren

Voor een eerste managed pilot is minimaal de Nudge app nodig.

Gebruik bij voorkeur:

`Nudge-2.1.3.81860.pkg`

Voor productie of bredere pilot kan later ook `Nudge_Essentials` of `Nudge_Suite` gebruikt worden, afhankelijk van hoe de LaunchAgent beheerd wordt.

Controle op een Mac:

```bash
ls -la /Applications/Utilities/Nudge.app
```

Verwachte uitkomst:

```text
/Applications/Utilities/Nudge.app
```

## Stap 2: Nudge Configuratie Uploaden

Upload dit bestand in Intune als macOS Custom profile:

`managed-device/com.github.macadmins.Nudge.pilot.mobileconfig`

Aanbevolen assignment:

- Alleen pilotgroep
- Nog niet `All Devices`
- Bij voorkeur dezelfde test/acceptatiegroep die ook voor macOS updatevalidatie wordt gebruikt

Waarom:

- De config gebruikt `latest-supported`.
- Als een device up-to-date is, zal Nudge niet verschijnen.
- Als een device achterloopt, zal Nudge de gebruiker informeren en naar updategedrag sturen.

## Stap 3: Nudge Notifications Uploaden

Upload dit bestand als apart macOS Custom profile:

`managed-device/com.github.macadmins.Nudge.notifications.mobileconfig`

Dit profiel staat meldingen toe voor:

`com.github.macadmins.Nudge`

Waarom:

- Jullie bestaande updatebeleid staat macOS Software Update meldingen toe.
- Nudge heeft daarnaast eigen meldingsrechten nodig voor consistente gebruikercommunicatie.
- Zonder notification profile kan de pilot stiller lijken dan bedoeld.

## Stap 4: Eerste Managed Device Test

Test op een managed Mac in de pilotgroep.

Controleer eerst of de app aanwezig is:

```bash
ls -la /Applications/Utilities/Nudge.app
```

Controleer of de profielen aanwezig zijn:

```bash
profiles show | grep -i "Nudge"
```

Start Nudge handmatig:

```bash
/Applications/Utilities/Nudge.app/Contents/MacOS/Nudge
```

Bekijk logs:

```bash
log show --last 10m --predicate 'subsystem == "com.github.macadmins.Nudge"' --style compact
```

Of live:

```bash
log stream --predicate 'subsystem == "com.github.macadmins.Nudge"' --style syslog --color none
```

## Verwachte Testuitkomsten

### Device is up-to-date

Nudge kan direct afsluiten.

Voorbeeld uit logs:

```text
SOFA Matched OS Version: 26.6.1
Current operating system (26.6.1) is greater than or equal to required operating system (26.6.1)
Device is fully updated
Nudge is terminating due to condition met
```

Dit is correct gedrag.

### Device loopt achter

Nudge toont de update-UI met:

- vereiste macOS-versie
- deadline
- deferral-knoppen
- updateknop
- uitleg dat de update automatisch door de organisatie kan worden geïnstalleerd

Dit is het gewenste pilotgedrag.

## Relatie Met De 3-Dagen Intune Enforcement

De huidige Intune policy dwingt de nieuwste update af na 3 dagen.

Daarom gebruikt Nudge ook een 3-dagen lijn voor de SOFA/SLA-bepaling:

```json
"standardMinorUpdateSLA": 3,
"standardMajorUpgradeSLA": 3,
"nonActivelyExploitedCVEsMinorUpdateSLA": 3,
"nonActivelyExploitedCVEsMajorUpgradeSLA": 3,
"activelyExploitedCVEsMinorUpdateSLA": 3,
"activelyExploitedCVEsMajorUpgradeSLA": 3
```

Hierdoor zegt Nudge niet iets anders dan Intune doet. De gebruiker krijgt dus geen melding zoals "je hebt 7 dagen" terwijl Intune na 3 dagen al afdwingt.

De Nudge pilot is daarnaast ingericht als zachte reminder met 15 gebruikers-deferrals:

```json
"allowedDeferrals": 15,
"allowedDeferralsUntilForcedSecondaryQuitButton": 15,
"initialRefreshCycle": 86400,
"approachingRefreshCycle": 86400,
"imminentRefreshCycle": 86400,
"elapsedRefreshCycle": 86400,
"nudgeRefreshCycle": 86400
```

Waarom:

- Gebruiker kan de Nudge reminder meerdere keren uitstellen tijdens de pilot.
- De pilot blijft vriendelijk en meetbaar zonder dat Nudge zelf hard gaat afdwingen.
- Intune/DDM blijft los daarvan de update afdwingen volgens de bestaande update policy.

Nudge is dus bewust niet ingericht als extra enforcement-laag. De technische enforcement blijft bij Intune/DDM.

## Wat Nudge Niet Doet In Deze Pilot

Nudge doet in deze pilot niet het volgende:

- Apps blokkeren
- Apps afsluiten
- Intune/DDM enforcement vervangen
- Compliance bepalen

De standaard macOS/System Settings software update notificatie wordt voor deze pilot wel uitgeschakeld via Intune-beleid, omdat Nudge de communicatie richting de gebruiker overneemt.

Dat is bewust. De eerste pilot valideert alleen:

- Nudge app installatie
- Profile delivery via Intune
- SOFA-resolutie
- Gebruiker-UI
- Logging
- Samenloop met bestaande Intune/DDM updatepolicy

## Test Zonder Managed Device

Op een losse VM zonder Intune kan alleen Nudge zelf getest worden:

- start de app
- leest de JSON/profile
- toont de UI
- verwerkt SOFA
- schrijft logs

Op een niet-managed VM test je niet betrouwbaar:

- DDM enforcement
- Intune install time om 12:30
- Intune update notifications
- policy assignment gedrag
- compliance block gedrag

Voor de echte validatie is een managed pilotdevice nodig.

## Rollback

Omdat Nudge los van de bestaande baseline wordt uitgerold, is rollback eenvoudig:

1. Unassign de Nudge configuration profile.
2. Unassign de Nudge notification profile.
3. Verwijder eventueel de Nudge app assignment.

De bestaande Intune macOS update policy blijft dan gewoon actief.

## Aanbevolen Pilotvolgorde

1. Test lokaal op VM met geforceerde versie, bijvoorbeeld `99.99.99`.
2. Test lokaal op VM met `latest-supported`.
3. Upload Nudge app naar Intune.
4. Pas de bestaande Software Update/App Store notification policy aan zodat `Disable Software Update Notifications` op `True` staat voor de pilotgroep.
5. Upload `managed-device/com.github.macadmins.Nudge.pilot.mobileconfig`.
6. Upload `managed-device/com.github.macadmins.Nudge.notifications.mobileconfig`.
7. Assign alles aan een kleine managed pilotgroep.
8. Controleer profile delivery en logs.
9. Test met een device dat up-to-date is.
10. Test met een device dat bewust achterloopt.
11. Pas teksten en deferrals aan op basis van feedback.

## WhatsApp Samenvatting

Nudge vervangt Intune/DDM niet. Intune blijft de update downloaden/installeren en afdwingen na 3 dagen om 12:30. We schakelen de standaard System Settings update-notificatie uit, zodat Nudge de communicatie overneemt. Nudge toont dag 1 en dag 2 een wegklikbare reminder; dag 3 is Intune enforcement.
