import pytest
def sum(num1, num2):
  return num1 + num2

def name():
  return "Ofer Bakria"

@pytest.mark.skip
def test_sum_with_zero():
  assert sum(0, 1) == 2, "Test failed! Wrong total when adding regular number with zero" 

@pytest.mark.skip
def test_sum_regular():
  assert sum(1,2) == 3, "Test failed! Wrong total when adding two regular numbers" 

@pytest.mark.parametrize("num1, num2", [(1, 2),(2,0)]) 
def test_sum_low_values(num1,num2):
    assert num1+num2 < 3 , f"Expected the sum to be lower than 3, but got {num1+num2}"
    
@pytest.mark.skip
def test_name():
  assert name() == "Ofer Bakria", "Test failed! the name should be Ofer Bakria" 