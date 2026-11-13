"""Student-owned tests: full branch coverage of the four supplied loss routines.
Original coverage-src and original unittest/framework sources stay unchanged.
"""
import sys
import unittest
from framework import AssemblyTest, print_coverage, _venus_default_args
from tools.check_hashes import check_hashes

class LossTests:
    routine = ""
    def exercise(self, a, b, expected, code=None):
        t = AssemblyTest(self, "../coverage-src/" + self.routine + ".s")
        t.input_array("a0", t.array(a))
        t.input_array("a1", t.array(b))
        t.input_scalar("a2", len(a) if code is None else code)
        result = t.array([-99] * max(1, len(a)))
        t.input_array("a3", result)
        t.call(self.routine)
        if code is None:
            t.check_array(result, expected)
            if self.routine != "zero_one_loss":
                t.check_scalar("a0", sum(expected))
        t.execute(code=0 if code is None else 36)
    def test_zero_length(self): self.exercise([0], [0], [], code=0)
    def test_negative_length(self): self.exercise([0], [0], [], code=-1)
    @classmethod
    def tearDownClass(cls): print_coverage(cls.routine + ".s", verbose=False)

class TestAbsLoss(LossTests, unittest.TestCase):
    routine = "abs_loss"
    def test_simple(self): self.exercise([1,-8,5,0], [3,-2,5,-1], [2,6,0,1])
    def test_single(self): self.exercise([-9], [7], [16])

class TestSquaredLoss(LossTests, unittest.TestCase):
    routine = "squared_loss"
    def test_simple(self): self.exercise([1,-8,5,0], [3,-2,5,-1], [4,36,0,1])
    def test_single(self): self.exercise([3], [-4], [49])

class TestZeroOneLoss(LossTests, unittest.TestCase):
    routine = "zero_one_loss"
    def test_simple(self): self.exercise([1,-8,5,0], [3,-2,5,0], [0,0,1,1])
    def test_single(self): self.exercise([-9], [-9], [1])

class TestInitializeZero(unittest.TestCase):
    def make(self, length, code=0, fail=""):
        t = AssemblyTest(self, "../coverage-src/initialize_zero.s")
        t.input_scalar("a0", length)
        t.call("initialize_zero")
        if not code: t.check_array_pointer("a0", [0] * length)
        t.execute(code=code, fail=fail)
    def test_simple(self): self.make(17)
    def test_single(self): self.make(1)
    def test_zero_length(self): self.make(0, code=36)
    def test_negative_length(self): self.make(-1, code=36)
    def test_malloc_failure(self): self.make(3, code=26, fail="malloc")
    @classmethod
    def tearDownClass(cls): print_coverage("initialize_zero.s", verbose=False)

if __name__ == "__main__":
    split_idx = sys.argv.index("--")
    _venus_default_args.extend(sys.argv[split_idx + 1:])
    check_hashes()
    unittest.main(argv=sys.argv[:split_idx])
