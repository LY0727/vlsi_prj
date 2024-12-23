`timescale 1ns / 1ps

module tb_lock();

reg clr;
reg [3:0] din;	//数字键
reg cancel;	    //取消键'*'
reg confirm;	//确定键'#'
wire unlock_ok;	//开锁,输出 1
wire reset_ok;	//成功重设密码，输出 1
wire locking;	//输错密码锁定状态,输出 1


reg clk;
always #10 clk = ~clk;	//晶振周期 20ns


/* 仿真测试 
基本开锁功能测试：
    依次输入正确的密码 1 2 3 4，然后按确认键，验证是否成功开锁。
错误密码输入测试：
    依次输入错误的密码 1 2 3 5，然后按确认键，验证是否无法开锁。
超级密码功能测试：
    依次输入超级密码 230419 两次，
    然后输入新密码 6789 两次，验证是否成功修改密码。
连续输错密码测试：
    连续输入错误密码 1234 三次，验证是否进入锁定状态。
锁定状态测试：
    在锁定状态下，输入任何密码 6789，验证是否无法开锁。
取消功能测试：  
    在输入过程中按取消键，验证是否取消操作。

*/

initial begin
clk <= 0;
confirm <= 0;
din <= 0;
cancel <= 0;
clr <= 1;

#30
clr <= 0;
#40
//依次输入 1 2 3 4 确认,成功开锁
    din <= 1;
    #20
    din <= 2;
    #20
    din <= 3;
    #20
    din <= 4;

    #20
    din <= 0;
    confirm <= 1;
    #20
    confirm <= 0;
    #20
    #20
    #20
    #20

//依次输入 1 2 3 5 确认,无法开锁

    din <= 1;
    #20
    din <= 2;
    #20
    din <= 3;
    #20
    din <= 5;
    #20
    din <= 0;
    confirm <= 1;
    #20
    confirm <= 0;
    din <= 1;
    #20
    din <= 0;
    #20
    #20
    #20
    #20

//依次输入 230419 230419 6789 6789 确认
//密码从默认的 1234 修改为 6789

    din <= 2; #20
    din <= 3; #20
    din <= 0; #20
    din <= 4; #20
    din <= 1; #20
    din <= 9; #20

    din <= 2; #20
    din <= 3; #20
    din <= 0; #20
    din <= 4; #20
    din <= 1; #20
    din <= 9; #20

    din <= 6; #20
    din <= 7; #20
    din <= 8; #20
    din <= 9; #20

    din <= 6; #20
    din <= 7; #20
    din <= 8; #20
    din <= 9; #20
    confirm <= 1; #20
    confirm <= 0; din <= 0; #20

//连续输入 3 次错误密码：
//1234 # 1234 # 1234 #
    din <= 1; confirm <= 0; #20
    din <= 2; #20
    din <= 3; #20
    din <= 4; #20

    din <= 0; confirm <= 1; #20
    din <= 1; confirm <= 0; #20
    din <= 2; #20
    din <= 3; #20
    din <= 4; #20
    
    din <= 0; confirm <= 1; #20
    din <= 1; confirm <= 0; #20
    din <= 2; #20
    din <= 3; #20
    din <= 4; #20
    din <= 0; confirm <= 1; #20


//连续输错三次后，进入 lock 状态，无法开锁

    din <= 6; confirm <= 0; #20
    din <= 7; #20
    din <= 8; #20
    din <= 9; #20
    din <= 0; confirm <= 1; #20

//中途取消 test
    din <= 6; confirm <= 0; #20
    din <= 7; #20
    din <= 8; #20
    cancel <= 1; din <= 0; #20
    din <= 9; cancel <= 0; #20
    din <= 0; confirm <= 1; #20
    confirm <= 0;

// 添加结束条件
    #100;
    $finish;
end

lock test_lock(
    .clk(clk),
    .clr(clr),
    .din(din),
    .confirm(confirm),
    .cancel(cancel),
    .unlock_ok(unlock_ok),
    .reset_ok(reset_ok),
    .locking(locking)
);


initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_lock);    //tb模块名称
end

endmodule