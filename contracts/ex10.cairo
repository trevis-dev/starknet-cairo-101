######### Ex 10
## Composability
# In this exercise, you need to:
# - Use this contract to retrieve the address of contract ex10b.cairo, which holds the key to this exercise
# - Find the secret key in ex10b.cairo
# - Call claim_points() in this exercise with the secret value
# - Your points are credited by the contract



%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import (assert_not_zero, assert_le)
from starkware.starknet.common.syscalls import (get_caller_address)
from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer
)

from contracts.utils.Iex10b import Iex10b

#
# Declaring storage vars
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
#

@storage_var
func ex10b_address_storage() -> (ex10b_address_storage: felt):
end

#
# View functions
#
@view
func ex10b_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (ex10b_address: felt):
    let (ex10b_address) = ex10b_address_storage.read()
    return (ex10b_address)
end

#
# Constructor
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _tderc20_address: felt,
        _players_registry: felt,
        _workshop_id: felt,
        _exercise_id: felt  
    ):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id)
    return ()
end

#
# External functions
# Calling this function will simply credit 2 points to the address specified in parameter
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(secret_value_i_guess: felt, next_secret_value_i_chose: felt):
    # Reading caller address
    let (sender_address) = get_caller_address()

    # Retrieve secret value by READING 
    let (ex10b_address) = ex10b_address_storage.read()
    let (secret_value) = Iex10b.secret_value(contract_address=ex10b_address)
    assert secret_value = secret_value_i_guess

    # choosing next secret_value for contract 10b. We don't want 0, it's not funny
    assert_not_zero(next_secret_value_i_chose)
    Iex10b.change_secret_value(contract_address=ex10b_address, new_secret_value= next_secret_value_i_chose)

    # Checking if the user has validated the exercise before
    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    distribute_points(sender_address, 2)
    return ()
end


##
## Temporary functions, will remove once account contracts are live and usable with Nile
##
##
@storage_var
func setup_is_finished() -> (setup_is_finished : felt):
end

@external
func set_ex_10b_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(ex10b_address: felt):
    let (permission) = setup_is_finished.read()
    assert permission = 0
    ex10b_address_storage.write(ex10b_address)
    setup_is_finished.write(1)
    return()
end
