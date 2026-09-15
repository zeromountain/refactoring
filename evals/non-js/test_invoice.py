import unittest
from invoice import print_invoice

CUSTOMERS = {"c1": {"type": "vip"}, "c2": {"type": "member"}, "c3": {"type": "regular"}}


class InvoiceTest(unittest.TestCase):
    def test_vip(self):
        self.assertEqual(print_invoice("c1|A,2,1000|B,1,500", CUSTOMERS),
                         "A 2 2000\nB 1 500\ntotal 2000.0\nVIP thanks\n")

    def test_member_under_threshold(self):
        self.assertEqual(print_invoice("c2|A,1,1000", CUSTOMERS), "A 1 1000\ntotal 3400.0\n")

    def test_member_over_threshold(self):
        self.assertEqual(print_invoice("c2|A,1,60000", CUSTOMERS), "A 1 60000\ntotal 54000.0\n")

    def test_regular(self):
        self.assertEqual(print_invoice("c3|A,1,1000", CUSTOMERS), "A 1 1000\ntotal 4000\n")


if __name__ == "__main__":
    unittest.main()
