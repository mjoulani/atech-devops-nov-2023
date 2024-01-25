import pytest
@pytest.mark.parametrize("num1, num2, num3", [(1, 2, 3), (1, 2, 12)]) 
def test_sum(num1, num2, num3):
    assert num1 + num2 == num3, "Got error in test_sum!" 