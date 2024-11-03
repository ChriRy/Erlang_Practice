-module(program_server).
-export([start/0, cli/0, user_select/2, loop/0]).

start() -> spawn(fibonacci_server, loop, []).

user_select(Pid, What) ->
    rpc(Pid, What).
rpc(Pid, Request) ->
    Pid ! {self(), Request},
    receive
        {Pid, Response} ->
            Response
    end.

loop() ->
    receive
        {From, {fibonacci, MaxValue}} ->
            % Call the Fibonacci generator
            Result = generate_fibonacci(MaxValue),
            % Send back the result
            From ! {self(), Result},
            loop();
        {From, {factorial, Value}} ->
            Result = factorial(Value),
            From ! {self(), Result},
            loop();
        {From, Other} ->
            % Handle unknown requests
            From ! {self(), {error, Other}},
            loop()
    end.

% Command Line interface to handle user input ------------------------------------------------------------------------------
cli() ->
    io:format("Starting program server... ~n"),
    %start the server and get it's Pid
    Pid = start(),
    read_input(Pid).

read_input(Pid) ->
    io:format("~n~n1. Fibonacci (MaxValue)"),
    io:format("~n2. Lucas (MaxValue)"),
    io:format("~n3. Factorial (Value)"),
    io:format("~n4. Quit~n"),
    case io:get_line("> ") of
        "1\n" ->
            io:format("Enter a max value for the fibonacci sequence: "),
            MaxValue = io:get_line(""),
            case string:to_integer(string:trim(MaxValue)) of
                {Number, []} when Number > 0 ->
                    Result = generate_fibonacci(Number),
                    io:format("Fibonacci Sequence up to ~p: ~p", [Number, Result]),
                    read_input(Pid);
                _ ->
                    io:format("Sorry, not a valid number. "),
                    read_input(Pid)
            end;
        "2\n" ->
            io:format("Enter a max value for the lucas sequence: "),
            MaxValue = io:get_line(""),
            case string:to_integer(string:trim(MaxValue)) of
                {Number, []} when Number > 0 ->
                    Result = generate_lucas(Number),
                    io:format("Lucas Sequence up to ~p: ~p", [Number, Result]),
                    read_input(Pid);
                _ ->
                    io:format("Sorry, not a valid number. "),
                    read_input(Pid)
            end;
        "3\n" ->
            io:format("Enter a number to get the factorial of: "),
            Value = io:get_line(""),
            case string:to_integer(string:trim(Value)) of
                {Number, []} when Number > 0 ->
                    Result = factorial(Number),
                    io:format("Factorial of ~p is ~p~n", [Number, Result]),
                    read_input(Pid);
                _ ->
                    io:format("Sorry, not a valid number. ~n"),
                    read_input(Pid)
            end;
        "4\n" ->
            io:format("Quitting program. ~n");
        _ ->
            io:format("Not a valid option, please try again. ")
    end.

% Code for fibonacci sequence -----------------------------------------------------------------------------------------------
generate_fibonacci(MaxValue) ->
    % Starts generating the fibonacci list with 0 & 1 (first two numbers), the MaxValue, and an empty list for the values
    generate_fibonacci_helper(0, 1, MaxValue, []).

% Generates sequence while the given A is less than the Max
generate_fibonacci_helper(A, B, MaxValue, Acc) when A =< MaxValue ->
    generate_fibonacci_helper(B, A + B, MaxValue, [A | Acc]);
% Runs when A becomes larger/equal to the MaxValue, flips the list to be in the correct order
generate_fibonacci_helper(_, _, _, Acc) ->
    lists:reverse(Acc).

% Code for Lucas numbers -----------------------------------------------------------------------------------------------------
generate_lucas(MaxValue) ->
    % Starts generating the lucas list with 2 and 1 (first two numbers), the MaxValue, and an empty list for the values
    generate_lucas_helper(2, 1, MaxValue, []).

% Generates sequence while the given A is less than the Max
generate_lucas_helper(A, B, MaxValue, Acc) when A =< MaxValue ->
    generate_lucas_helper(B, A + B, MaxValue, [A | Acc]);
% Runs when A becomes larger/equal to the MaxValue, flips the list to be in the correct order
generate_lucas_helper(_, _, _, Acc) ->
    lists:reverse(Acc).

% Code for factorials -------------------------------------------------------------------------------------------------------
factorial(Value) when Value < 0 ->
    % Handle negative input
    {error, negative};
factorial(0) ->
    % Base Case, 0! = 1
    1;
factorial(N) ->
    % Recursive Case
    N * factorial(N - 1).
