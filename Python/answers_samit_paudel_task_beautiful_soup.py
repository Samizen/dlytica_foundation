import csv
from urllib.parse import urljoin
from datetime import datetime
import requests
from bs4 import BeautifulSoup
import re

BASE = "https://quotes.toscrape.com/"

def clean_quote(text):
    """Remove all weird symbols and leading/trailing quotes from the quote."""
    # Remove unwanted characters
    text = text.replace("â€œ", "").replace("â€", "")
    # Remove any other leading/trailing quotation marks or unusual symbols
    text = re.sub(r"^[“”\"']+|[“”\"']+$", "", text)
    return text.strip()

def clean_location(loc):
    """Remove leading 'in ' from location."""
    return loc.replace("in ", "").strip()

def normalize_date(date_str):
    """Convert date to uniform format: DD-MMM-YYYY"""
    for fmt in ("%B %d, %Y", "%d-%b-%y", "%d-%b-%Y"):
        try:
            dt = datetime.strptime(date_str, fmt)
            return dt.strftime("%d-%b-%Y")
        except ValueError:
            continue
    return date_str

session = requests.Session()
author_cache = {}

with open("quotes.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["Quote", "Author", "Born Date", "Born Location"])

    url = BASE  # start at homepage
    while url:
        resp = session.get(url, timeout=15)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "html.parser")

        for q in soup.select("div.quote"):  # q is a Tag
            text_el = q.select_one("span.text")
            author_el = q.select_one("small.author")
            about_a = q.select_one('a[href^="/author/"]')

            if not (text_el and author_el and about_a and about_a.has_attr("href")):
                continue  # skip malformed blocks

            quote_text = clean_quote(text_el.get_text(strip=True))
            author = author_el.get_text(strip=True)
            about_url = urljoin(BASE, about_a["href"])

            # cache author page to reduce requests
            if author not in author_cache:
                a_resp = session.get(about_url, timeout=15)
                a_resp.raise_for_status()
                a_soup = BeautifulSoup(a_resp.text, "html.parser")
                born_date = a_soup.select_one(".author-born-date")
                born_loc = a_soup.select_one(".author-born-location")

                born_date_text = normalize_date(born_date.get_text(strip=True)) if born_date else ""
                born_loc_text = clean_location(born_loc.get_text(strip=True)) if born_loc else ""
                author_cache[author] = (born_date_text, born_loc_text)

            born_date_text, born_loc_text = author_cache[author]
            writer.writerow([quote_text, author, born_date_text, born_loc_text])

        # follow pagination
        next_a = soup.select_one("li.next a")
        url = urljoin(BASE, next_a["href"]) if next_a and next_a.has_attr("href") else None

print("Saved to quotes.csv")
