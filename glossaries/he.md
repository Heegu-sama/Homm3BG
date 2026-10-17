# Hebrew (he)

## Style notes

- Terms below are **defaults**, not hard rules. If the default sounds wrong in a specific sentence, use the listed variant (or another natural phrasing) — readability wins over mechanical consistency.
- Prefer **active voice**. Hebrew is an active language; rephrase passive constructions (״נעשה שימוש״, ״מסומן ב...״, ״מוסבר ב...״) with an active subject, e.g. ״ספר חוקים זה משתמש באופן עקבי באותם מונחים״.
- Address the reader in **second person plural** (אתם, שלכם, תוכלו). Do not mix with singular (אתה, שלך).
- Imperatives in rules use plural form: "שלפו קלף", "השליכו קלף", "הניחו קובייה".
- Names are **not translated**: Faction names (Castle, Rampart, ...), Hero names (Catherine, Sandro, ... — printed on the Hero cards) and scenario titles. Wrap them in `\textenglish{...}`; wrap multi-word names in `\mbox{}` so they do not break across lines.
- Example player names that are common in Hebrew are written in Hebrew: Alice = אליס, Bob = בוב.
- Names of specific game elements — units (Evil Eyes, Griffins, Pit Lords), spells, artifacts, abilities, heroes' cards — are **names**: write the English as printed on the components, followed by the Hebrew in parentheses, at the first mention in each paragraph/example: `\textenglish{Evil Eyes} (עיני הרשע)`. Later mentions in the same paragraph may use the Hebrew alone. Exception: Halberdiers stays English only (`\textenglish{Halberdiers}`). Generic categories (יחידות קשתים, יחידה נייטרלית, קלף קסם) are not names and stay Hebrew.
- A specific card title referred to as a card (captions, "the Bag of Gold card", card-anatomy examples) is written in English as printed, followed by the Hebrew in parentheses: `\textenglish{Bag of Gold} (שק זהב)`. The game components are English-only, so the reader must be able to find the card. Card *type* captions (Event card, Spell card) are Hebrew only.
- `\wikilink` to a specific card: put the Hebrew inside the label and wrap the whole label in `\texthebrew` so the ° marker lands at the end in reading order (also inside note boxes): `\wikilink{spells/magic_arrow}{\texthebrew{\textenglish{Magic Arrow} (חץ קסם)}}`.
- Building names printed on the Town Board (City Hall, Citadel, Mage Guild, Unit Dwellings, Faction Buildings) are written in English followed by the Hebrew in parentheses where they are introduced: `\textbf{\textenglish{City Hall}} (בית העירייה)`. Later mentions may use the Hebrew alone.
- Any Latin text inside Hebrew (names, `AI`, `MP`, `HP`, Roman numerals such as `II--III`) must be wrapped in `\textenglish{...}`, otherwise it renders mirrored. Never type it backwards as a workaround.
- Multi-digit numbers render reversed in RTL text: wrap them in `\textenglish{}` (e.g. `\textenglish{10}`). Never type numbers backwards. Ranges: `\textenglish{1--3}`.
- `--` does not become a dash in Hebrew text; use a real en dash `–` in Hebrew prose.
- Letter labels (a, b, c, …) become Hebrew numeral letters: א ב ג ד ה ו ז ח ט י יא יב יג … (never כ/ל for the 11th/12th). Callouts inside pictures read number then letter, right-to-left: `\encircle{\rtlrun{4א}}`, `\encircle{\rtlrun{4יא}}`.
- `\pagelink{anchor}{label}`, `\pagetarget{anchor}{label}`, `\ref*{anchor}`, `\wikilink{path}{label}`: anchors and paths stay in English, only labels are translated. `\index{...}` entries are translated.
- Quotes: use Hebrew gershayim-style quotes ״...״ for quoted terms; use the geresh/gershayim characters (׳ ״) in abbreviations.
- Hyphen after a prefix letter before a number or Latin word: ה-\textenglish{AI}, ב-3, ל-\textenglish{Castle}.
- Tables, image rows and column layouts read right-to-left. Verify every table and image grid in the built PDF.

## Factions

Faction names are not translated (use `\textenglish{...}`).

| English | Hebrew |
|---|---|
| castle | Castle |
| conflux | Conflux |
| cove | Cove |
| dungeon | Dungeon |
| fortress | Fortress |
| inferno | Inferno |
| necropolis | Necropolis |
| rampart | Rampart |
| stronghold | Stronghold |
| tower | Tower |

## Units

| English | Hebrew |
|---|---|
| boars | חזירי בר |
| champions | אבירי עלית |
| deck of unit cards | חפיסת קלפי יחידות |
| dendroids | דנדרואידים |
| dread knights | אבירי אימה |
| familiars | שדונים |
| few | ״מעטים״ |
| griffins | גריפונים |
| hp | נקודות חיים (\textenglish{HP}) |
| liches | ליצ׳ים |
| marksmen | קשתים |
| neutral units | יחידות נייטרליות |
| pack | ״רבים״ |
| recruited or reinforced | גויסו או תוגברו |
| reinforce | לתגבר |
| reinforced | תוגבר / מתוגבר |
| summoned elementals | יסודות מזומנים |
| tier (bronze/silver/gold/azure) | דרגה (ארד/כסף/זהב/תכלת) |
| unit cards | קלפי יחידות |
| unit miniatures | מיניאטורות יחידות |
| units | יחידות |
| zealots | קנאים |

## Heroes

| English | Hebrew |
|---|---|
| ability | יכולת |
| class | מקצוע |
| experience | ניסיון |
| expert effects | אפקטי מומחה |
| hero board | לוח הגיבור |
| hero | גיבור |
| heroes | גיבורים |
| hire (a hero) | לגייס |
| level effects | אפקטי הרמות |
| level tracker | מד הרמות |
| level | רמה |
| main hero | גיבור ראשי |
| might / magic (hero type) | כוח / קסם (גיבור כוח, גיבור קסם) |
| movement points | נקודות תנועה |
| MP | נקודות תנועה (\textenglish{MP}) |
| power | עוצמה |
| secondary hero | גיבור משני |
| specialty | מומחיות |

## Map Locations

| English | Hebrew |
|---|---|
| center field | השדה המרכזי |
| central map tile | אריח המפה המרכזי |
| creature bank | מאגר יצורים |
| dragon utopia | ממלכת הדרקונים |
| far map tile | אריח מפה רחוק |
| field | שדה |
| flag (verb) | לכבוש |
| flaggable | ניתן לכיבוש |
| locations | מיקומים |
| map tile | אריח מפה |
| mines | מכרות |
| monolith | מונוליט |
| near map tile | אריח מפה קרוב |
| obelisk | אובליסק |
| random town | עיר אקראית |
| redwood observatory | מצפה רדווד |
| revisitable | ניתן לביקור חוזר |
| sea map tile | אריח ים |
| settlement | יישוב |
| starting (i) map tile | אריח התחלתי (\textenglish{I}) |
| subterranean gate | שער תת-קרקעי |
| subterranean map tile | אריח תת-קרקעי |
| surface tile | אריח שטח |
| tile | אריח |
| trading post | עמדת מסחר |
| visit / visitable | לבקר / ניתן לביקור |
| water wheel | גלגל מים |
| whirlpool | מערבולת |

## Resources

| English | Hebrew |
|---|---|
| building materials | אבנים (the icon shows ore) |
| gold | זהב |
| grail token | אסימון הגרייל |
| resource dice | קוביות משאבים |
| resource production tracker | מד ייצור המשאבים |
| resources | משאבים |
| treasure die | קוביית אוצר |
| valuables | קריסטלים (the icon shows crystals) |

## Deck-building

| English | Hebrew |
|---|---|
| ability card | קלף יכולת |
| deck | חפיסה |
| decks | חפיסות |
| discard pile | ערימת ההשלכה |
| discard | להשליך (השליכו) |
| draw | לשלוף (שלפו) |
| empower | להעצים |
| empowered ability card | קלף יכולת מועצמת |
| empowered ability token | אסימון יכולת מועצמת |
| empowered statistic card | קלף סטטיסטיקה מועצם |
| expert (effect) | (אפקט) מומחה |
| hand limit | מגבלת קלפים ביד |
| instant / activation / ongoing / permanent | מיידי / הפעלה / מתמשך / קבוע |
| minor / major / relic (artifact) | משני / עיקרי / אגדי |
| pandora's box card | קלף תיבת פנדורה |
| player decks | חפיסות השחקנים |
| search | לחפש (חפשו) |
| specialty card | קלף מומחיות |
| spell cards | קלפי קסם |
| spell scroll | מגילת קסם |
| statistic card | קלף סטטיסטיקה |
| summoned unit card | קלף יחידה מזומנת |

## Spells

| English | Hebrew |
|---|---|
| expert spells / basic spells | קסמים מתקדמים / קסמים בסיסיים |
| Combat Penalty (roll two Attack Dice, use the lower) | חיסרון קרב (״סובלת מחיסרון קרב״, ״ללא חיסרון״); not קנס/עונש |
| Implosion (spell) | קריסה |
| haste | מהירות |
| magic arrow | חץ קסם |
| school | אסכולה (אסכולת קסם) |

## AI Deck

| English | Hebrew |
|---|---|
| AI | \textenglish{AI} (ה-\textenglish{AI}) |
| ai deck | חפיסת ה-\textenglish{AI} |
| magic card | קלף קסם |
| might card | קלף כוח |
| skill card | קלף מיומנות |

## Town

| English | Hebrew |
|---|---|
| town | עיר |
| build token | אסימון בנייה |
| buildings | מבנים |
| citadel | מצודה |
| city hall | בית העירייה |
| dwelling | מגורים (מגורי יחידות) |
| faction buildings | מבני סיעה |
| mage guild | גילדת הקוסמים |
| population token | אסימון אוכלוסייה |
| spell book token | אסימון ספר קסמים |
| town board | לוח העיר |
| town card | קלף עיר |

## Combat

| English | Hebrew |
|---|---|
| activate / activation | להפעיל / הפעלה |
| arrow tower | מגדל חצים |
| attack | התקפה |
| back line | קו עורפי |
| combat board | לוח הקרב |
| combat round | סבב קרב |
| combat | קרב |
| damage | נזק |
| defense | הגנה |
| defend | להתגונן |
| elemental damage | נזק יסודות |
| front line | קו חזית |
| initiative | יוזמה |
| negative morale | מורל שלילי |
| obstacle | מכשול |
| paralysis | שיתוק |
| positive morale | מורל חיובי |
| retaliation / retaliate | התקפת נגד / לבצע התקפת נגד |
| retreat | נסיגה / לסגת (variant: לברוח, when natural) |
| surrender | כניעה / להיכנע |
| winning combat | ניצחון בקרב |

## Battlefield

| English | Hebrew |
|---|---|
| adventure card | קלף הרפתקה |
| adventure mode | מצב הרפתקה |
| alliance | ברית (מצב ברית, תרחישי ברית) |
| battlefield board | לוח שדה הקרב |
| battlefield obstacles | מכשולי שדה הקרב |
| battlefield | שדה הקרב |
| campaign | קמפיין |
| clash | עימות |
| combat power level | רמת כוח קרבי |
| cooperative | שיתוף פעולה (heading/mode name); שיתופי where an adjective reads better (״במשחק שיתופי״) |
| final combat | הקרב הסופי |
| scenario | תרחיש |
| skirmish mode | מצב התגוששות |
| tournament | טורניר |

## Keywords

| English | Hebrew |
|---|---|
| attack token | אסימון התקפה |
| clone token | אסימון שיבוט |
| corrosion token | אסימון חלודה |
| Necromancy (ability) / necromancers | נקרומנסיה / נקרומנסרים |
| Demoniacs (Inferno hero class) | אחוזי דיבוק |
| fire wall token | אסימון חומת אש |
| force field token | אסימון שדה כוח |
| land mine token | אסימון מוקש |
| miniatures | מיניאטורות |
| quicksand token | אסימון חול טובעני |
| stack token | אסימון ערימה |
| summon token | אסימון זימון |
| time token | אסימון זמן |
| weakness token | אסימון חולשה |

## Other

| English | Hebrew |
|---|---|
| artifact | חפץ |
| astrologers proclaim card | קלף ״האסטרולוגים מכריזים״ |
| attack dice | קוביות התקפה |
| black cubes | קוביות שחורות |
| core rulebook | ספר החוקים הבסיסי |
| effects | אפקטים |
| event card | קלף אירוע |
| expert effect markers | סמני אפקט מומחה |
| faction cubes | קוביות סיעה |
| faction | סיעה (variant: צבא, when natural) |
| game setup | הכנת המשחק |
| index | מפתח |
| map setup | הכנת המפה |
| mission book | ספר המשימות |
| player elimination | הדחת שחקן |
| player setup | הכנת השחקנים |
| round tracker | מד הסבבים |
| round | סבב |
| turn | תור |
| victory points | נקודות ניצחון; abbreviation נ״נ, spelled out with (נ״נ) at first use |
| mulligan | החלפת יד פתיחה (not מוליגן — unfamiliar jargon) |
| war machine | מכונת מלחמה |
