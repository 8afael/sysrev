"""seed_countries_and_languages

Revision ID: 46a37e2b3df0
Revises: 083341295de1
Create Date: 2026-07-15 20:10:50.521443

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '46a37e2b3df0'
down_revision: Union[str, None] = '083341295de1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Tabelas de referência rápida para o bulk_insert
    countries_table = sa.table(
        'countries',
        sa.column('id', sa.Integer),
        sa.column('name', sa.String),
        sa.column('code', sa.String)
    )

    languages_table = sa.table(
        'languages',
        sa.column('id', sa.Integer),
        sa.column('name', sa.String),
        sa.column('code', sa.String)
    )

    countries_data = [
            # --- América do Sul ---
            {"name": "Argentina", "code": "ARG"},
            {"name": "Bolivia", "code": "BOL"},
            {"name": "Brazil", "code": "BRA"},
            {"name": "Chile", "code": "CHL"},
            {"name": "Colombia", "code": "COL"},
            {"name": "Ecuador", "code": "ECU"},
            {"name": "Guyana", "code": "GUY"},
            {"name": "Paraguay", "code": "PRY"},
            {"name": "Peru", "code": "PER"},
            {"name": "Suriname", "code": "SUR"},
            {"name": "Uruguay", "code": "URY"},
            {"name": "Venezuela", "code": "VEN"},

            # --- América Central e Caribe ---
            {"name": "Belize", "code": "BLZ"},
            {"name": "Costa Rica", "code": "CRI"},
            {"name": "Cuba", "code": "CUB"},
            {"name": "Dominica", "code": "DMA"},
            {"name": "Dominican Republic", "code": "DOM"},
            {"name": "El Salvador", "code": "SLV"},
            {"name": "Grenada", "code": "GRD"},
            {"name": "Guatemala", "code": "GTM"},
            {"name": "Haiti", "code": "HTI"},
            {"name": "Honduras", "code": "HND"},
            {"name": "Jamaica", "code": "JAM"},
            {"name": "Nicaragua", "code": "NIC"},
            {"name": "Panama", "code": "PAN"},
            {"name": "Puerto Rico", "code": "PRI"},
            {"name": "Bahamas", "code": "BHS"},
            {"name": "Barbados", "code": "BRB"},

            # --- América do Norte ---
            {"name": "Canada", "code": "CAN"},
            {"name": "Mexico", "code": "MEX"},
            {"name": "United States", "code": "USA"},

            # --- Europa ---
            {"name": "Albania", "code": "ALB"}, {"name": "Andorra", "code": "AND"},
            {"name": "Austria", "code": "AUT"}, {"name": "Belgium", "code": "BEL"},
            {"name": "Bosnia and Herzegovina", "code": "BIH"}, {"name": "Bulgaria", "code": "BGR"},
            {"name": "Croatia", "code": "HRV"}, {"name": "Cyprus", "code": "CYP"},
            {"name": "Czech Republic", "code": "CZE"}, {"name": "Denmark", "code": "DNK"},
            {"name": "Estonia", "code": "EST"}, {"name": "Finland", "code": "FIN"},
            {"name": "France", "code": "FRA"}, {"name": "Georgia", "code": "GEO"},
            {"name": "Germany", "code": "DEU"}, {"name": "Greece", "code": "GRC"},
            {"name": "Hungary", "code": "HUN"}, {"name": "Iceland", "code": "ISL"},
            {"name": "Ireland", "code": "IRL"}, {"name": "Italy", "code": "ITA"},
            {"name": "Latvia", "code": "LVA"}, {"name": "Liechtenstein", "code": "LIE"},
            {"name": "Lithuania", "code": "LTU"}, {"name": "Luxembourg", "code": "LUX"},
            {"name": "Malta", "code": "MLT"}, {"name": "Monaco", "code": "MCO"},
            {"name": "Montenegro", "code": "MNE"}, {"name": "Netherlands", "code": "NLD"},
            {"name": "Norway", "code": "NOR"}, {"name": "Poland", "code": "POL"},
            {"name": "Portugal", "code": "PRT"}, {"name": "Romania", "code": "ROU"},
            {"name": "Russia", "code": "RUS"}, {"name": "Serbia", "code": "SRB"},
            {"name": "Slovakia", "code": "SVK"}, {"name": "Slovenia", "code": "SVN"},
            {"name": "Spain", "code": "ESP"}, {"name": "Sweden", "code": "SWE"},
            {"name": "Switzerland", "code": "CHE"}, {"name": "Ukraine", "code": "UKR"},
            {"name": "United Kingdom", "code": "GBR"},

            # --- Ásia e Oriente Médio ---
            {"name": "Afghanistan", "code": "AFG"}, {"name": "Armenia", "code": "ARM"},
            {"name": "Azerbaijan", "code": "AZE"}, {"name": "Bahrain", "code": "BHR"},
            {"name": "Bangladesh", "code": "BGD"}, {"name": "Cambodia", "code": "KHM"},
            {"name": "China", "code": "CHN"}, {"name": "India", "code": "IND"},
            {"name": "Indonesia", "code": "IDN"}, {"name": "Iran", "code": "IRN"},
            {"name": "Iraq", "code": "IRQ"}, {"name": "Israel", "code": "ISR"},
            {"name": "Japan", "code": "JPN"}, {"name": "Jordan", "code": "JOR"},
            {"name": "Kazakhstan", "code": "KAZ"}, {"name": "South Korea", "code": "KOR"},
            {"name": "Kuwait", "code": "KWT"}, {"name": "Lebanon", "code": "LBN"},
            {"name": "Malaysia", "code": "MYS"}, {"name": "Maldives", "code": "MDV"},
            {"name": "Mongolia", "code": "MNG"}, {"name": "Nepal", "code": "NPL"},
            {"name": "Oman", "code": "OMN"}, {"name": "Pakistan", "code": "PAK"},
            {"name": "Philippines", "code": "PHL"}, {"name": "Qatar", "code": "QAT"},
            {"name": "Saudi Arabia", "code": "SAU"}, {"name": "Singapore", "code": "SGP"},
            {"name": "Sri Lanka", "code": "LKA"}, {"name": "Syria", "code": "SYR"},
            {"name": "Taiwan", "code": "TWN"}, {"name": "Thailand", "code": "THA"},
            {"name": "Turkey", "code": "TUR"}, {"name": "United Arab Emirates", "code": "ARE"},
            {"name": "Uzbekistan", "code": "UZB"}, {"name": "Vietnam", "code": "VNM"},

            # --- África ---
            {"name": "Algeria", "code": "DZA"}, {"name": "Angola", "code": "AGO"},
            {"name": "Benin", "code": "BEN"}, {"name": "Botswana", "code": "BWA"},
            {"name": "Cameroon", "code": "CMR"}, {"name": "Egypt", "code": "EGY"},
            {"name": "Ethiopia", "code": "ETH"}, {"name": "Ghana", "code": "GHA"},
            {"name": "Kenya", "code": "KEN"}, {"name": "Libya", "code": "LBY"},
            {"name": "Madagascar", "code": "MDG"}, {"name": "Morocco", "code": "MAR"},
            {"name": "Mozambique", "code": "MOZ"}, {"name": "Nigeria", "code": "NGA"},
            {"name": "Senegal", "code": "SEN"}, {"name": "South Africa", "code": "ZAF"},
            {"name": "Tunisia", "code": "TUN"}, {"name": "Zimbabwe", "code": "ZWE"},

            # --- Oceania ---
            {"name": "Australia", "code": "AUS"}, {"name": "New Zealand", "code": "NZL"}
        ]

    languages_data = [
            {"name": "Arabic", "code": "ar"}, {"name": "Bengali", "code": "bn"},
            {"name": "Bulgarian", "code": "bg"}, {"name": "Catalan", "code": "ca"},
            {"name": "Chinese (Simplified)", "code": "zh-CN"}, {"name": "Chinese (Traditional)", "code": "zh-TW"},
            {"name": "Croatian", "code": "hr"}, {"name": "Czech", "code": "cs"},
            {"name": "Danish", "code": "da"}, {"name": "Dutch", "code": "nl"},
            {"name": "English", "code": "en"}, {"name": "Estonian", "code": "et"},
            {"name": "Finnish", "code": "fi"}, {"name": "French", "code": "fr"},
            {"name": "German", "code": "de"}, {"name": "Greek", "code": "el"},
            {"name": "Hebrew", "code": "he"}, {"name": "Hindi", "code": "hi"},
            {"name": "Hungarian", "code": "hu"}, {"name": "Indonesian", "code": "id"},
            {"name": "Italian", "code": "it"}, {"name": "Japanese", "code": "ja"},
            {"name": "Korean", "code": "ko"}, {"name": "Latvian", "code": "lv"},
            {"name": "Lithuanian", "code": "lt"}, {"name": "Malay", "code": "ms"},
            {"name": "Norwegian", "code": "no"}, {"name": "Persian", "code": "fa"},
            {"name": "Polish", "code": "pl"}, {"name": "Portuguese", "code": "pt"},
            {"name": "Romanian", "code": "ro"}, {"name": "Russian", "code": "ru"},
            {"name": "Slovak", "code": "sk"}, {"name": "Slovenian", "code": "sl"},
            {"name": "Spanish", "code": "es"}, {"name": "Swedish", "code": "sv"},
            {"name": "Thai", "code": "th"}, {"name": "Turkish", "code": "tr"},
            {"name": "Ukrainian", "code": "uk"}, {"name": "Vietnamese", "code": "vi"}
        ]

# Executa a inserção em massa de forma segura
    op.bulk_insert(countries_table, countries_data)
    op.bulk_insert(languages_table, languages_data)


def downgrade() -> None:
    # Se desfizer a migração, limpa as tabelas
    op.execute("DELETE FROM countries;")
    op.execute("DELETE FROM languages;")