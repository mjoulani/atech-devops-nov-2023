import unittest
import questions
from python_katas.utils import unittest_runner


class TestSumOfElements(unittest.TestCase):

    def test_empty_list(self):
        lst = []
        self.assertEqual(questions.sum_of_element(lst), 0)

    def test_integers_list(self):
        lst = [1, 2, 3, 4, 5]
        self.assertEqual(questions.sum_of_element(lst), 15)

    def test_negative_numbers(self):
        lst = [1, -6, 7, 0, 99]
        self.assertEqual(questions.sum_of_element(lst), 101)

    def test_all_zeros(self):
        lst = [0] * 50000
        self.assertEqual(questions.sum_of_element(lst), 0)


class TestVerbing(unittest.TestCase):

    def test_short_word(self):
        self.assertEqual(questions.versing('run'), 'runing')

    def test_long_word(self):
        self.assertEqual(questions.versing('python'), 'pythoning')

    def test_short_word_ending_with_ing(self):
        self.assertEqual(questions.versing('sing'), 'singly')

    def test_long_word_ending_with_ing(self):
        self.assertEqual(questions.versing('coding'), 'codingly')


class TestWordsConcatenation(unittest.TestCase):

    def test_list(self):
        lst = ["take", "me", "home"]
        self.assertEqual(questions.words_concatenation(lst), 'take me home', 'Should be "take me home"')

    def test_long_list(self):
        lst = ["take", "me", "home", "country", "road"]
        self.assertEqual(questions.words_concatenation(lst), 'take me home country road', 'Should be "take me home country road"')


class TestReverseWordsConcatenation(unittest.TestCase):
    def test_sample(self):
        self.assertEqual(questions.reverse_words_concatenation(['take', 'me', 'home']), 'home me take', 'Should be "home me take"')
        pass


class TestIsUniqueString(unittest.TestCase):
    def test_sample(self):
        self.assertEqual(questions.is_unique_string("aaabcd"), False,'Each letter should has only one appearance')
        pass


class TestListDiff(unittest.TestCase):

    def test_sample(self):
        self.assertEqual(questions.list_diff([1, 2, 3, 4, 7, 11]), [None, 1, 1, 1, 3, 4])
        pass
    def test_sample2(self):
        self.assertEqual(questions.list_diff([]), [])
        pass



class TestPrimeNumber(unittest.TestCase):

    def test_sample(self):
        self.assertEqual(questions.prime_number(2), True)
        pass
    def test_sample2(self):
        self.assertEqual(questions.prime_number(50), False)
        pass


class TestPalindromeNum(unittest.TestCase):
    def test_sample(self):
        self.assertEqual(questions.palindrome_num(1441), True)
        pass
    def test_sample2(self):
        self.assertEqual(questions.palindrome_num(50), False)
        pass


class TestPairMatch(unittest.TestCase):
    def test_sample(self):
        self.assertEqual(questions.pair_match({"John": 20, "Abraham": 45},{"July": 18, "Kim": 26}), ("John","July"))
        pass
    def test_sample2(self):
        self.assertEqual(questions.pair_match({"John": 20, "Abraham": 60},{"July": 18, "Kim": 59}), ("Abraham","Kim"),"must be ('Abraham','Kim')")
        pass

class TestBadAverage(unittest.TestCase):

    def test_sample(self):
        self.assertEqual(questions.bad_average(1,2,3), 2)
        pass


class TestBestStudent(unittest.TestCase):
    def test_sample(self):
        dict={
        "Ben": 78,
        "Hen": 88,
        "Natan": 99,
        "Efraim": 100,
        "Rachel": 95
    }
        self.assertEqual(questions.best_student(dict), "Efraim")
        pass


class TestPrintDictAsTable(unittest.TestCase):
    def test_sample(self):
        dict = {
            "Ben": 78,
            "Hen": 88,
            "Natan": 99,
            "Efraim": 100,
            "Rachel": 95
        }
        self.assertEqual(questions.print_dict_as_table(dict), None)
        pass


class TestMergeDicts(unittest.TestCase):
    def test_sample(self):
        dict1 = {'a': 1}
        dict2 = {'b': 2}
        self.assertEqual(questions.merge_dicts(dict1,dict2), {'a':1,'b':2})
        pass


class TestSevenBoom(unittest.TestCase):
    def test_sample(self):
        self.assertEqual(questions.seven_boom(30), [7, 14, 17, 21, 27, 28])
        pass


class TestCaesarCipher(unittest.TestCase):
    def test_sample(self):
        self.assertEqual(questions.caesar_cipher("Fly Me To The Moon"), "Iob Ph Wr Wkh Prrq")
        pass


class TestSumOfDigits(unittest.TestCase):
    def test_sample(self):
        self.assertEqual(questions.sum_of_digits("2524"), 13)
        pass
    def test_sample2(self):
        self.assertEqual(questions.sum_of_digits("0"), 0)
        pass
    def test_sample3(self):
        self.assertEqual(questions.sum_of_digits("00232"), 7)

        pass


if __name__ == '__main__':
    import inspect
    import sys

    unittest_runner(inspect.getmembers(sys.modules[__name__], inspect.isclass))


