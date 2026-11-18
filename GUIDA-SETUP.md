# MENTALITYX — guida per attivare il sito gratuitamente

Questa cartella contiene il sito responsive, il pannello amministratore, la logica di registrazione, commenti e votazioni. Per rendere i dati condivisi tra tutti i visitatori va collegato un progetto Supabase e pubblicato il sito.

## 1) Crea il database gratuito
1. Vai su https://supabase.com e crea un account gratuito.
2. Crea un nuovo progetto, nome `mentalityx` e scegli una password database robusta (conservala in un password manager). La regione più vicina all'Italia è normalmente una regione europea.
3. Apri **SQL Editor** → **New query**.
4. Apri il file `schema.sql`, copia tutto il contenuto, incollalo nell'editor e premi **Run**.

## 2) Crea il tuo account amministratore
1. Nel progetto Supabase apri **Authentication → Users** e premi **Add user**.
2. Inserisci la TUA email e scegli una password forte. Se disponibile, conferma/verifica l'utente dal pannello.
3. Copia l'UUID dell'utente appena creato.
4. Torna in **SQL Editor** ed esegui questa query, sostituendo l'UUID con quello appena copiato:

```sql
update public.profiles
set role = 'admin'
where id = 'INCOLLA-QUI-UUID-UTENTE';
```

Questo passaggio è ciò che rende il tuo account amministratore. Non condividere la password con nessuno. Non creare un account admin tramite la registrazione pubblica.

## 3) Collega il sito a Supabase
1. In Supabase apri **Project Settings → API** (in alcune interfacce: **Project Settings → API Keys**).
2. Copia il **Project URL** e la chiave **anon / publishable** (NON la `service_role` e NON una secret key).
3. Apri `index.html` con un editor di testo.
4. Cerca queste due righe e sostituisci i valori tra apici:

```js
const SUPABASE_URL = 'INSERISCI_SUPABASE_PROJECT_URL';
const SUPABASE_ANON_KEY = 'INSERISCI_SUPABASE_ANON_KEY';
```

La chiave anon/publishable è pensata per essere usata nel browser: la sicurezza dipende dalle policy RLS contenute in `schema.sql`. Non inserire mai la service_role key nel file HTML.

## 4) Pubblica gratis su Cloudflare Pages
1. Crea un account gratuito su https://github.com e uno su https://dash.cloudflare.com.
2. Crea un repository GitHub chiamato `mentalityx` e carica i file di questa cartella (`index.html`, `schema.sql`, `GUIDA-SETUP.md`).
3. In Cloudflare vai su **Workers & Pages → Create → Pages → Connect to Git**.
4. Collega GitHub e scegli il repository `mentalityx`.
5. Framework preset: **None**. Build command: lascia vuoto. Build output directory: `/` (se l'interfaccia non accetta `/`, usa `.`).
6. Premi Deploy. Cloudflare assegna un indirizzo gratuito tipo `mentalityx.pages.dev` (il nome può essere occupato; in quel caso scegli una variante).

## 5) Come gestire il sito
- Accedi dal pulsante **ACCEDI** usando l'email e la password dell'account admin creato in Supabase.
- In fondo alla pagina compare **AREA AMMINISTRATORE**.
- Inserisci titolo, tipo (TikTok / YouTube / Immagine), link e descrizione; premi **PUBBLICA CONTENUTO**.
- Puoi modificare o eliminare i contenuti dalla lista nel pannello.
- I visitatori possono guardare senza account; per votare o commentare devono registrarsi.
- Ogni account può votare una sola volta per ciascun contenuto. La classifica usa i voti reali del database.

## Note importanti
- Le immagini si pubblicano tramite URL pubblico. Per immagini caricate dal computer serve aggiungere uno storage bucket (si può fare nel piano gratuito, entro i limiti del servizio); questa prima versione accetta URL immagine.
- Per TikTok, alcuni post non consentono l'embed: in quel caso il sito mostra il collegamento per aprirli su TikTok.
- L'invio di email di conferma Supabase ha limiti nel piano gratuito. Per i test puoi verificare l'utente dal pannello Supabase; per un lancio pubblico conviene configurare un provider SMTP.
- Non sono state inventate credenziali: la password amministratore la scegli tu in fase di creazione dell'utente. Non inviare mai qui la tua password.
- Il pacchetto è un progetto pronto da configurare, non un sito già pubblicato: l'attivazione richiede i passaggi esterni sopra descritti.
