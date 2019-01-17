-record(position,{x, y, next_x, next_y}).

-record(world_parameters,{cars_start_amount, car_speed}).

-record(car,{pid, destination, position = #position{}, world_parameters = #world_parameters{}, timer_ref, making_move}).

-record(car_generator,{map = #{}, world_parameters = #world_parameters{}}).