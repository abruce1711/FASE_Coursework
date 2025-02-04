with Ada.Text_IO; use Ada.Text_IO;
package Reactor with SPARK_mode
is
   subtype ControlRods is Integer range 0..5;
   subtype WaterSupply is Integer range 0..100;
   subtype Temperature is Integer range 0..100;
   subtype TemperatureIncrease is Integer range 0..5;
   subtype ReactorPower is Integer range 0..10;
   subtype Electricity is Integer range 0..200;
   type Power is(On, Off);

   currentPowerStatus : Power := Off;
   currentRods : ControlRods := ControlRods'Last;
   currentWaterSupply : WaterSupply := WaterSupply'Last;
   currentTemperature : Temperature := Temperature'First;
   currentTemperatureIncrease : TemperatureIncrease := 1;
   currentReactorPower : ReactorPower := 1;
   currentElectricityProduced : Electricity := Electricity'First;
   currentMaxElectricity : Electricity := Electricity'First;
   InputConst : Integer := 0;

   function ReactorCheck return Boolean is
     (currentTemperature < Temperature'Last and currentWaterSupply > WaterSupply'First);

   function ReactorOn return Boolean is
      (currentPowerStatus = On);

   procedure startReactor with
     Global => (In_Out => (currentPowerStatus, currentMaxElectricity), Input => currentRods, Proof_in => (currentWaterSupply,currentTemperature)),
     Pre => currentPowerStatus = Off and ReactorCheck and currentRods = ControlRods'Last,
     Post => ReactorOn;

   procedure stopReactor with
     Global => (In_Out => currentPowerStatus, Output => currentMaxElectricity),
     Pre => currentPowerStatus = On,
     Post => currentPowerStatus = Off;

   procedure removeControlRod with
     Global => (In_Out => (currentRods, currentTemperatureIncrease, currentReactorPower), Proof_In => (currentWaterSupply,currentTemperature), Output => currentMaxElectricity, Input => currentPowerStatus),
     Pre => currentRods > ControlRods'First and ReactorCheck and ReactorOn,
     Post => currentRods = currentRods'Old-1 and ReactorCheck;

   procedure addControlRod with
     Global => (In_Out => (currentRods, currentTemperatureIncrease, currentReactorPower), Output => currentMaxElectricity, Input => currentPowerStatus),
     Pre => currentRods < ControlRods'Last,
     Post => currentRods = currentRods'Old+1;

   procedure increaseTemperature (temp : out Integer) with
     Global => (In_Out => currentTemperature, Input => (currentTemperatureIncrease, currentPowerStatus)),
     Pre => currentTemperature < Temperature'Last,
     Post => currentTemperature >= currentTemperature'Old;

   procedure decreaseTemperature (temp : out Integer) with
     Global => (In_Out => currentTemperature, Input => currentWaterSupply),
     Pre => currentTemperature > Temperature'First,
     Post => currentTemperature <= currentTemperature'Old;

   procedure increaseElectricity (elec : out Integer) with
     Global => (In_Out => currentElectricityProduced, Input => (currentReactorPower, currentMaxElectricity)),
     Pre => currentElectricityProduced <= currentMaxElectricity,
     Post => currentElectricityProduced = currentElectricityProduced'Old+currentReactorPower or currentElectricityProduced = currentMaxElectricity;

   procedure decreaseWaterSupply with
     Global => (In_Out => currentWaterSupply, Input => currentPowerStatus),
     Pre => currentWaterSupply > 0 and ReactorOn,
     Post => currentWaterSupply = currentWaterSupply'Old-1;

   procedure fillWaterSupply with
     Global => (In_Out => currentWaterSupply),
     Pre => currentWaterSupply < WaterSupply'Last,
     Post => currentWaterSupply = WaterSupply'Last;


end Reactor;
