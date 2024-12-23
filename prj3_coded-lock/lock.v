/*
基本功能：
    1.基本开锁功能:输入4位密码，按确认键开锁。   开锁后保持30s。 这里设置为3 cycle
    2.错误处理:连续3次输错密码后锁定3分钟。                     这里设置为3 cycle
    3.超级密码功能:输入6位超级密码后，可以重设4位开锁密码。
    4.取消功能:在输入过程中可以按取消键取消操作。
*/

module lock(
    input wire clk,
    input wire clr,
    input wire [3:0] din,       //数字键
    input wire cancel,          //取消键'*'
    input wire confirm,         //确定键'#'

    output reg unlock_ok,       //开锁,输出 1
    output reg reset_ok,        //成功重设密码，输出 1
    output reg locking          //输错密码死锁状态,输出 1
);

// 初始密码1234
reg [3:0] passwd0 = 1;
reg [3:0] passwd1 = 2;
reg [3:0] passwd2 = 3;
reg [3:0] passwd3 = 4;

// 超级密码230419
reg [3:0] superwd0 = 2;
reg [3:0] superwd1 = 3;
reg [3:0] superwd2 = 0;
reg [3:0] superwd3 = 4;
reg [3:0] superwd4 = 1;
reg [3:0] superwd5 = 9;

// 新密码
reg [3:0] newpasswd0 = 0, newpasswd1 = 0, newpasswd2 = 0, newpasswd3 = 0;
// 开启状态保持时间
reg [5:0] open_time = 0;
// 连续输错密码次数
reg [5:0] wrong_count = 0;
// 锁定状态保持时间
reg [5:0] lock_time = 0;
// 状态定义    没有用到next_state 寄存器
// 如果使用 always_ff 的形式，一个reg就够了，两个反而不好写
// 如果使用 显示dff+组合逻辑 的形式，next_state_s 定义为wire就行，写组合逻辑就行了
reg [3:0] present_state_s, next_state_s;
reg [4:0] present_state_t, next_state_t;

// 状态机S状态定义
localparam S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011;
localparam S4 = 3'b100, Open = 3'b101, Lock = 3'b110;

// 状态机T状态定义
localparam T0 = 5'b00000, T1 = 5'b00001, T2 = 5'b00010, T3 = 5'b00011, T4 = 5'b00100;
localparam T5 = 5'b00101, T6 = 5'b00110, T7 = 5'b00111, T8 = 5'b01000, T9 = 5'b01001;
localparam T10 = 5'b01010, T11 = 5'b01011, T12 = 5'b01100, T13 = 5'b01101, T14 = 5'b01110;
localparam T15 = 5'b01111, T16 = 5'b10000, T17 = 5'b10001, T18 = 5'b10010, T19 = 5'b10011;
localparam T20 = 5'b10100, OK = 5'b10101;

// 自定义宏定义
`define OPEN_TIME 6'd3;
`define LOCK_TIME 6'd3;

// 检测确认键和取消键  这里设置了两按键同时有效时，confirm优先
`define check(confirm, cancel, passwdn, Sn)  \
    begin \
        if (confirm) begin \
            if(present_state_t == T20) \    //改密码成功的情况，把错误次数清零
                wrong_count <= 0; \
            else if (wrong_count == 2) begin \  
                wrong_count <= 0; \
                present_state_s <= Lock; \
                lock_time <= `LOCK_TIME; \
                locking <= 1; \
            end \
            else  begin \
                wrong_count <= wrong_count + 1 ; \
                present_state_s <= S0; \
            end \
        end \
        else if (cancel) \
            present_state_s <= S0; \
        else if (din == passwdn) \
            present_state_s <= Sn; \
        else \
            present_state_s <= S0; \
    end
// 超级密码输入
`define superwd_in(superwdn,Tn)  \
    begin \
        if (din == superwdn) present_state_t <= Tn; \
        else present_state_t <= T0; \
    end
// 新密码输入
`define newpasswd_in(newpasswdn,Tn)  \
    begin \
        newpasswdn <= din; \
        present_state_t <= Tn; \
    end
// 确认新密码
`define confirm_newpasswd(newpasswdn,Tn) \
    begin \
    if (din == newpasswdn) present_state_t <= Tn; \
    else present_state_t <= T0; \
    end 

/*
    实际密码锁应该有按键输入检测来作为逻辑更新触发条件， 
    这里是tb_lock.v中的按键输入激励设置得和工作频率一致，简化了
*/
// 状态机S   
always @(posedge clk or posedge clr) begin
    if (clr) begin
        present_state_s <= S0;
        unlock_ok <= 0;
        open_time <= 0;
        wrong_count <= 0;

        locking <= 0;  // 死锁状态
    end else begin
        case (present_state_s)    // 状态转移
            S0: `check(confirm, cancel,passwd0,S1)
            S1: `check(confirm,cancel,passwd1,S2)            
            S2: `check(confirm, cancel,passwd2,S3)            
            S3: `check(confirm, cancel,passwd3,S4)            
            // s4，对于用户来说与前四个状态并没有区别
            S4: begin
                if (confirm) begin
                    present_state_s <= Open;
                    unlock_ok <= 1;
                    open_time <= `OPEN_TIME;  // 开锁保持时间
                end
                else 
                    present_state_s <= S0;
            end
            Open: begin
                if (open_time == 1) begin
                    unlock_ok <= 0;
                    present_state_s <= S0;
                end 
                else begin
                    open_time <= open_time - 1;
                    present_state_s <= Open;
                end
            end
            Lock: begin
                if (lock_time == 1) begin
                    locking <= 0;       // 解除死锁状态
                    present_state_s <= S0;
                end 
                else begin
                    lock_time <= lock_time - 1;
                    present_state_s <= Lock;
                end
            end
            default: present_state_s <= S0;
        endcase
    end
end

// 状态机T
always @(posedge clk or posedge clr) begin
    if (clr) begin
        present_state_t <= T0;
        reset_ok <= 0;
    end else begin
        // 这里 cancel 逻辑可以抽出来
        if (cancel) 
            present_state_t <= T0;
        else begin
            case (present_state_t)
            // 输入超级密码 230419 两遍；
            T0: `superwd_in(superwd0,T1)
            T1: `superwd_in(superwd1,T2)
            T2: `superwd_in(superwd2,T3)
            T3: `superwd_in(superwd3,T4)
            T4: `superwd_in(superwd4,T5)
            T5: `superwd_in(superwd5,T6)
            T6: `superwd_in(superwd0,T7)
            T7: `superwd_in(superwd1,T8)
            T8: `superwd_in(superwd2,T9)
            T9: `superwd_in(superwd3,T10)
            T10:`superwd_in(superwd4,T11) 
            T11:`superwd_in(superwd5,T12) 
            // 输入新密码
            T12: `newpasswd_in(newpasswd0,T13)
            T13: `newpasswd_in(newpasswd1,T14)
            T14: `newpasswd_in(newpasswd2,T15)
            T15: `newpasswd_in(newpasswd3,T16)
            // 确认新密码
            T16: `confirm_newpasswd(newpasswd0,T17)
            T17: `confirm_newpasswd(newpasswd1,T18)
            T18: `confirm_newpasswd(newpasswd2,T19)
            T19: `confirm_newpasswd(newpasswd3,T20)
            // 这里考虑实际功能需求，等待confirm键确认,cancel键取消; 屏蔽数字输入
            T20: begin
                if (confirm) begin
                    present_state_t <= OK;
                    reset_ok <= 1;
                end                     
                else present_state_t <= T20;
            end
            OK: begin
                passwd0 <= newpasswd0;
                passwd1 <= newpasswd1;
                passwd2 <= newpasswd2;
                passwd3 <= newpasswd3;
                reset_ok <= 0;
                present_state_t <= T0;
                // 重设新密码应该有这个逻辑的，但这个写法会多驱动赋值， 
                // 可以写在第一个状态机 S 里面; 还是单独拿出来写比较好
                // wrong_count <= 0;
            end
            default: present_state_t <= T0;
        endcase
        end
    end
end



endmodule