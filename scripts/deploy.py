from brownie import accounts,lottery,network
import os
import time

account = accounts.add(os.getenv("PRIVATE_KEY"))

def set_Fees(lottery_object,price_usd):
    lottery_object.set_EntranceFees(price_usd,{"from":account})

def get_EntranceFees(lottery_object):
    return lottery_object.get_CurrentEntranceFees()

def start_Lottery(lottery_object):
    lottery_object.start_lottery()

def enter_Lottery(lottery_object,Fees):
    lottery_object.enter_lottery({"amount" :Fees})

def end_Lottery(lottery_object):
    lottery_object.end_lottery()
    
def set_Profit(lottery_object , profit_percentage):     
    lottery_object.set_profitrate(profit_percentage,{"from":account})

def announce_Winner(lottery_object):
    lottery_object.announce_winner()

def return_Winner(lottery_object):
    return lottery_object.view_winner()

def reset_Lottery(lottery_object):
    lottery_object.reset_Lottery()

def return_ContractBalance(lottery_object):
    return lottery_object.lottery_Balance()

def return_ContractProfits(lottery_object):
    return lottery_object.calculate_Ownerprofits()

def withdraw_Profits(lottery_object):
    lottery_object.withdraw_profits()

def reset_Lottery(lottery_object):
    lottery_object.reset_lottery()


def main():
    lottery_obj = lottery.deploy({"from":account},publish_source = True)
    set_Fees(lottery_obj,price_usd  = 50)
    fees = get_EntranceFees(lottery_obj)
    print("Current Entrance Fees : "+str(fees))
    set_Profit(lottery_obj,profit_percentage =10)
    start_Lottery(lottery_obj)
    enter_Lottery(lottery_obj,fees)
    curr_balance = return_ContractBalance(lottery_obj)
    print("Current Contract Balance : "+str(curr_balance))
    curr_profits = return_ContractProfits(lottery_obj)
    print("Current Contract Profits : "+str(curr_balance))
    end_Lottery(lottery_obj)
    print("5 minutes wait...")
    time.wait(300)
    announce_Winner(lottery_obj)
    winner = return_Winner(lottery_obj)
    print("Winner : "+str(winner))
    withdraw_Profits(lottery_obj)
    reset_Lottery(lottery_obj)
    

    
    