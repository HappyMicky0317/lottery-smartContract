from brownie import accounts,lottery,network
import os
def test_entrance():
    account = accounts.add(os.getenv("PRIVATE_KEY"))
    lottery_obj = lottery.deploy({"from":account})
    lottery_obj.brown(50,{"from":account})
    assert lottery_obj.get_CurrentEntranceFees() >1000000000000000
    assert lottery_obj.get_CurrentEntranceFees()<1300000000000000