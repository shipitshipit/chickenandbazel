import unittest


def calculate(lines) -> int:
    total = 0
    weights = {"MAJOR": 1000 * 1000, "MINOR": 1000, "PATCH": 1, "POINT": 1}
    prefixes = {
        "chore": "POINT",
        "doc": "POINT",
        "docs": "POINT",
        "feat": "MINOR",
        "fix": "POINT",
        "perf": "MINOR",
        "refactor": "MAJOR",
    }

    for l in lines:
        term = l.split(":")
        if term:
            found = term[0]
            print(f"1 {l} gave me {term} which offers {found}")
            term = found.split("(")
            found = term[0]
            print(f"2 {l} gave me {term} which offers {found}")
            if found in prefixes:
                pre = prefixes[found]
                print("gave a cost of {}".format(pre))
                if pre in weights:
                    print("gave a real cost of {}".format(weights[pre]))
                    total += weights[pre]
    return total


class TestWeights(unittest.TestCase):
    def test_dict_values(self):
        testcases = [
            {"data": ["doc: blah", "feat: blah"], "cost": 1 * 1000 + 1},
            {"data": ["refactor: blah", "fix: blah"], "cost": 1 * 1000 * 1000 + 1},
        ]

        for case in testcases:
            calc_cost = calculate(case["data"])
            self.assertEqual(
                calc_cost,
                case["cost"],
                msg=f"Calculated {calc_cost} should be {case['cost']}",
            )


if __name__ == "__main__":
    unittest.main()
