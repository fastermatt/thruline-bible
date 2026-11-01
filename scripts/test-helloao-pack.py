#!/usr/bin/env python3
"""Offline checks for resource-packs/*.json (no network): the committed pack must decode as
Thruline's ResourceBook shape, match its manifest hash, and disclose its known upstream gaps."""
import hashlib
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKS = ROOT / "resource-packs"
CANON = set(("GEN EXO LEV NUM DEU JOS JDG RUT 1SA 2SA 1KI 2KI 1CH 2CH EZR NEH EST JOB PSA PRO ECC SNG ISA JER LAM EZK DAN "
             "HOS JOL AMO OBA JON MIC NAM HAB ZEP HAG ZEC MAL MAT MRK LUK JHN ACT ROM 1CO 2CO GAL EPH PHP COL 1TH 2TH "
             "1TI 2TI TIT PHM HEB JAS 1PE 2PE 1JN 2JN 3JN JUD REV").split())
ANCHOR_KEYS = {"book", "chapterStart", "verseStart", "chapterEnd", "verseEnd"}


class PackTests(unittest.TestCase):
    def packs(self):
        found = sorted(PACKS.glob("*.manifest.json"))
        self.assertTrue(found, "no pack manifests found")
        for manifest_path in found:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            pack_path = ROOT / manifest["pack"]["file"]
            yield manifest, pack_path, pack_path.read_bytes()

    def test_hash_and_size_match_manifest(self):
        for manifest, _path, blob in self.packs():
            self.assertEqual(hashlib.sha256(blob).hexdigest(), manifest["pack"]["sha256"])
            self.assertEqual(len(blob), manifest["pack"]["bytes"])
            self.assertLess(len(blob), 40 * 1024 * 1024, "the app refuses packs over 40 MB")

    def test_pack_is_a_valid_resource_book(self):
        for manifest, _path, blob in self.packs():
            book = json.loads(blob)
            self.assertEqual(set(book), {"id", "title", "author", "attribution", "source", "articles"})
            self.assertEqual(book["id"], manifest["id"])
            self.assertTrue(book["attribution"].strip())
            ids = [a["id"] for a in book["articles"]]
            self.assertEqual(len(ids), len(set(ids)), "article ids must be unique")
            self.assertEqual(len(ids), manifest["built"]["articles"])
            for a in book["articles"]:
                self.assertEqual(set(a), {"id", "title", "body", "anchor"})
                self.assertTrue(a["body"].strip(), a["id"])
                anchor = a["anchor"]
                self.assertEqual(set(anchor), ANCHOR_KEYS)
                self.assertIn(anchor["book"], CANON, a["id"])
                self.assertLessEqual(anchor["chapterStart"], anchor["chapterEnd"])
                if anchor["chapterStart"] == anchor["chapterEnd"]:
                    self.assertLessEqual(anchor["verseStart"], anchor["verseEnd"], a["id"])

    def test_known_upstream_gaps_are_disclosed_not_hidden(self):
        for manifest, _path, blob in self.packs():
            book = json.loads(blob)
            covered = {a["anchor"]["book"] for a in book["articles"]}
            declared = set(manifest["built"]["booksNotCoveredUpstream"])
            self.assertEqual(CANON - covered, declared, "uncovered books must match the manifest")
            bodies = {a["id"]: a["body"] for a in book["articles"]}
            for art_id in manifest["built"]["introductionsCutByUpstream"]:
                self.assertIn("digitization ends here", bodies[art_id])

    def test_license_record_is_public_domain_mark(self):
        for manifest, _path, _blob in self.packs():
            self.assertEqual(manifest["upstream"]["licenseUrl"], "https://creativecommons.org/publicdomain/mark/1.0/")

    def test_raw_chapter_hashes_cover_every_chapter(self):
        for manifest, _path, _blob in self.packs():
            self.assertEqual(len(manifest["rawChapterSha256"]), manifest["built"]["chapters"])


if __name__ == "__main__":
    unittest.main()
