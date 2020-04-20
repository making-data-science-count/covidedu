from __future__ import annotations

import logging
import os
import re
import typing

import lxml.html
import pandas as pd
import requests


def main():
    """
       Small scripting example of how I imagine the WebpageParser class to be used to scrape data.  This doesn't address
       how you'd want it to be stored and some of the problems that come with that - e.g., PDFs are often binary.
    """
    logging.basicConfig(level=logging.INFO)

    sample_run_size = 3

    keywords = ['covid', 'corona', 'closure']

    data_path = os.path.join(os.path.dirname(__file__), os.pardir, 'data', 'district-data-to-scrape.csv')
    df = pd.read_csv(data_path)

    for ix, row in df.iterrows():
        url = row['url']
        nces_id = row['nces_id']

        webpage = WebpageParser(url)

        for keyword in keywords:
            for text in webpage.text_surrounding_keyword(keyword, n_char_buffer=30):
                print(nces_id, keyword, text)

        for link in webpage.generate_links(keywords):
            print(nces_id, 'link match', link)

        if ix == sample_run_size - 1:  # Just breaking after a few for the example
            break

        print()


class WebpageParser(object):
    def __init__(self, url: str):
        self.url = url
        self.html = self.get_html()
        self.root = self.get_html_root_element()
        self.links = list(self.generate_links())

    def count_mentions_of_keyword(self, keyword: str, case_sensitive: bool = False) -> int:
        """Counts number of string occurences in HTML text"""
        keyword = keyword if case_sensitive else keyword.lower()
        text = self.html if case_sensitive else self.html.lower()
        return text.count(keyword)

    def text_surrounding_keyword(self,
                                 keyword: str,
                                 n_char_buffer: int = 25,
                                 case_sensitive: bool = False) -> typing.Generator[str, None, None]:

        match_length = len(keyword)
        starting_locations = self._find_keyword_start_locations(
            keyword=keyword,
            case_sensitive=case_sensitive
        )
        for start_index in starting_locations:
            yield self.html[start_index - n_char_buffer:start_index + match_length + n_char_buffer].replace('\n', '')

    def get_html(self) -> str:
        """Returns HTML as text"""
        logging.info('requesting %s', self.url)
        response = requests.get(self.url)
        return response.text

    def get_html_root_element(self) -> lxml.html.HtmlElement:
        """Returns lxml HTML root"""
        return lxml.html.fromstring(self.html)

    def generate_links(self, contains: typing.Optional[typing.Union[str, typing.Sequence[str]]] = None) -> \
    typing.Generator[str, None, None]:
        """Generate properly resolved links from anchor elements from root HTML"""
        contains = contains if isinstance(contains, (type(None), list)) else [
            contains]  # Sorry this is convoluted for now

        for anchor in self.get_anchor_elements():
            try:
                href: str = anchor.attrib['href']

                if contains and not any([x.lower() in href.lower() for x in contains]):
                    logging.debug('href (%s) does not contain %s, skipping anchor element ... ', href, contains)
                    continue
                if href.startswith('http'):
                    yield href
                else:
                    yield self.url + href
            except KeyError:
                logging.debug('no href, skipping anchor element ... ')

    def get_anchor_elements(self) -> typing.List[lxml.html.HtmlElement]:
        return self.root.xpath('//a')

    def _find_keyword_start_locations(self, keyword: str, case_sensitive: bool = False) -> typing.List[int]:
        """returns start index integer list"""
        keyword = keyword if case_sensitive else keyword.lower()
        text = self.html if case_sensitive else self.html.lower()

        starting_locations = [x.start() for x in re.finditer(keyword, text)]
        return starting_locations

    def __repr__(self) -> str:
        return f'<WebpageParser for [{self.url}]>'


if __name__ == '__main__':
    main()
