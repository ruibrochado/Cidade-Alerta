import re
import csv
import requests
from bs4 import BeautifulSoup

URL = "https://anmp.pt/municipios/municipios/contactos/?cod=MUN"

# Casos especiais onde o email/slug não bate diretamente com o nome oficial
SPECIAL_CASES = {
    "cmah": "Angra do Heroísmo",
    "cmav": "Arcos de Valdevez",
    "mcr": "Câmara de Lobos",  # confirmar se este email está mesmo certo no teu output
    "cmca": "Carrazeda de Ansiães",
    "cm-fcr": "Figueira de Castelo Rodrigo",
    "cm-fec": "Freixo de Espada à Cinta",
    "cmhorta": "Horta",
    "idanha": "Idanha-a-Nova",
    "mpdelgada": "Ponta Delgada",
    "cmpb": "Ponte da Barca",
    "cmpr": "Peso da Régua",
    "cmvfc": "Vila Franca do Campo",
    "cmviana": "Viana do Castelo",
    "cm-gaia": "Vila Nova de Gaia",
    "cm-vnbarquinha": "Vila Nova da Barquinha",
    "cm-vncerveira": "Vila Nova de Cerveira",
    "cm-vnpaiva": "Vila Nova de Paiva",
    "cm-vfxira": "Vila Franca de Xira",
    "cm-vpaguiar": "Vila Pouca de Aguiar",
    "cm-vrsa": "Vila Real de Santo António",
    "cm-vvrodao": "Vila Velha de Ródão",
    "cm-vminho": "Vila Nova de Foz Côa",  # este convém rever no fim
    "cm-pvarzim": "Póvoa de Varzim",
    "cmpv": "Praia da Vitória",
    "cm-mdouro": "Miranda do Douro",
    "cm-oaz": "Oliveira de Azeméis",
    "cm-olb": "Oliveira do Bairro",
    "mun-planhoso": "Póvoa de Lanhoso",
    "mun-guarda": "Guarda",
    "mun-setubal": "Setúbal",
    "mun-sines": "Sines",
    "mun-montijo": "Montijo",
    "mun-trofa": "Trofa",
    "mun-aljustrel": "Aljustrel",
    "mun-celoricodebasto": "Celorico de Basto",
    "municipio-portodemos": "Porto de Mós",
    "municipioamares": "Amares",
    "municipio@chaves.pt": "Chaves",
    "oeiras": "Oeiras",
    "famalicao": "Vila Nova de Famalicão",
    "sjpesqueira": "São João da Pesqueira",
    "cm-sjm": "São João da Madeira",
    "cm-sbras": "São Brás de Alportel",
    "cm-smpenaguiao": "Santa Marta de Penaguião",
    "cm-spsul": "São Pedro do Sul",
    "cm-saoroquedopico": "São Roque do Pico",
    "cm-saovicente": "São Vicente",
    "cmnordeste": "Nordeste",
    "cmscflores": "Santa Cruz das Flores",
    "cm-graciosa": "Santa Cruz da Graciosa",
    "cm-stirso": "Santo Tirso",
}

def clean(s: str) -> str:
    return " ".join(s.split()).strip()

def slug_to_name(slug: str) -> str:
    slug = slug.strip().lower()

    if slug in SPECIAL_CASES:
        return SPECIAL_CASES[slug]

    # remover prefixos comuns
    for prefix in ["cm-", "mun-", "m-"]:
        if slug.startswith(prefix):
            slug = slug[len(prefix):]
            break

    # alguns emails aparecem sem prefixo
    slug = slug.replace("municipio-", "")
    slug = slug.replace("municipio", "")

    # converter hífen para espaço
    name = slug.replace("-", " ").strip()

    # title case simples
    words = []
    for word in name.split():
        if word in {"de", "da", "do", "das", "dos", "e"}:
            words.append(word)
        else:
            words.append(word.capitalize())

    return " ".join(words)

html = requests.get(URL, timeout=30).text
soup = BeautifulSoup(html, "html.parser")
text = soup.get_text("\n", strip=True)

emails = re.findall(r'[\w\.-]+@[\w\.-]+\.\w+', text)

rows = []
seen = set()

for email in emails:
    email = email.strip().lower()

    # ignorar contactos da própria ANMP
    if email.endswith("@anmp.pt"):
        continue

    local_part, domain = email.split("@", 1)

    # escolher a melhor base para deduzir o município
    # normalmente é o domínio sem .pt
    base = domain.removesuffix(".pt")

    # casos em que o domínio é genérico ou pouco útil:
    # usar o local_part
    if base in {"mail.telepac", "gmail", "sapo", "outlook", "hotmail"}:
        base = local_part

    # caso especial: se o email inteiro for um identificador conhecido
    if email in SPECIAL_CASES:
        municipality_name = SPECIAL_CASES[email]
    elif base in SPECIAL_CASES:
        municipality_name = SPECIAL_CASES[base]
    elif local_part in SPECIAL_CASES:
        municipality_name = SPECIAL_CASES[local_part]
    else:
        municipality_name = slug_to_name(base)

    key = (municipality_name.lower(), email)
    if municipality_name and key not in seen:
        seen.add(key)
        rows.append({
            "municipality_name": municipality_name,
            "email": email,
        })

with open("municipality_contacts.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["municipality_name", "email"])
    writer.writeheader()
    writer.writerows(rows)

print(f"CSV criado com {len(rows)} linhas.")
print("\nPrimeiras 30 linhas:")
for row in rows[:30]:
    print(row)