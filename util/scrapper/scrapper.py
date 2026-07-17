import re
import time
import requests
import pandas as pd

from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright


class CostScraper:

    def __init__(self):

        self.session = requests.Session()

        self.session.headers.update({

            "User-Agent": "Mozilla/5.0",
            "X-Requested-With": "XMLHttpRequest"

        })

    #######################################################

    def scrape(self, url):

        action = re.search(r"(CA\d+)", url).group(1)

        print(f"Action: {action}")

        members = self.read_members(url)

        print(f"{len(members)} membros encontrados")

        for i, member in enumerate(members, start=1):

            print(f"[{i}/{len(members)}] {member['Name']}")

            details = self.read_details(
                member["pid"],
                action
            )

            member.update(details)

            time.sleep(0.10)

        return pd.DataFrame(members)

    #######################################################

    def read_members(self, url):

        members = []

        with sync_playwright() as p:

            browser = p.chromium.launch(headless=True)

            page = browser.new_page()

            page.goto(url)

            page.wait_for_load_state("networkidle")

            #
            # abre aba Working Groups
            #

            page.locator("text=Working Groups and Membership").click()

            page.wait_for_timeout(3000)

            #
            # todas as linhas
            #

            items = page.locator("div.user-list__item")

            total = items.count()

            print(total)

            for i in range(total):

                item = items.nth(i)

                pid = item.get_attribute("data-user-pid")

                #
                # nome
                #

                spans = item.locator("h4 span").all_inner_texts()

                name = " ".join(
                    x.strip()
                    for x in spans
                )

                #
                # tenta descobrir o país
                #

                country = ""

                try:

                    tr = item.locator("xpath=ancestor::tr")

                    tds = tr.locator("td")

                    if tds.count():

                        country = tds.nth(0).inner_text().strip()

                except:
                    pass

                #
                # Working Group
                #

                wg = ""

                try:

                    row_text = tr.inner_text()

                    m = re.search(
                        r"(WG\s*\d+.*?)\n",
                        row_text
                    )

                    if m:

                        wg = m.group(1)

                except:
                    pass

                members.append({

                    "pid": pid,
                    "Name": name,
                    "Working Group": wg,
                    "Country": country

                })

            browser.close()

        #
        # remove duplicados
        #

        unique = {}

        for m in members:

            unique[m["pid"]] = m

        return list(unique.values())

    #######################################################

    def read_details(self, pid, action):

        url = (
            "https://www.cost.eu/wordpress/wp-admin/admin-ajax.php"
            f"?action=get_user_more_compact"
            f"&pid={pid}"
            f"&code={action}"
        )

        html = self.session.get(url).text

        soup = BeautifulSoup(html, "lxml")

        lines = [

            x.strip()

            for x in soup.get_text("\n").splitlines()

            if x.strip()

        ]

        institution = ""
        country = ""
        email = ""

        if "Address" in lines:

            idx = lines.index("Address")

            if idx + 1 < len(lines):
                institution = lines[idx + 1]

            if idx + 2 < len(lines):
                country = lines[idx + 2]

        for l in lines:

            if "@" in l:

                email = l

                break

        return {

            "Institution": institution,
            "Email": email,

            #
            # se vier país do endpoint,
            # ele é mais confiável
            #

            "Country": country if country else ""

        }


###########################################################

if __name__ == "__main__":

    URL = "https://www.cost.eu/actions/CA23126/"

    scraper = CostScraper()

    df = scraper.scrape(URL)

    print(df.head())

    df.to_csv(

        "members.csv",

        index=False,

        encoding="utf-8-sig"

    )

    print()

    print("Arquivo members.csv criado com sucesso.")