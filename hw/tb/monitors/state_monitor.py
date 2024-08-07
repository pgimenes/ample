
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge
import numpy as np
from tb.monitor import Monitor

from statistics import mean

class State_Monitor(Monitor):
  def __init__(self, dut, variant, logger, test_nodes=10):
    super().__init__(dut, variant)

    self.running = False
    self._log = logger
    self.nodeslot_count = int(dut.NODESLOT_COUNT.value)

    self.states = [
      "EMPTY",
      "PROG_DONE",
      "FETCH_NB_LIST",
      "FETCH_SCALE_FACTORS",
      "FETCH_NEIGHBOURS",
      "AGGREGATION",
      "TRANSFORMATION",
      "PASS",
      "WRITEBACK",
      "HALT"
    ]

    self.state_cycle_dict = {
      f'nodeslot_state[{ns}]': {state: [] for state in self.states} 
      for ns in range(self.nodeslot_count)
    }
    self.current_cycle = 0
    self.last_change_cycle = {f'nodeslot_state[{ns}]': 0 for ns in range(self.nodeslot_count)}
    self.previous_states = {f'nodeslot_state[{ns}]': 0 for ns in range(self.nodeslot_count)} #Init as zero otherwise will be Xs

  async def _run(self) -> None:
    while True:
      if not self.running: # Change to if self.stop
        return

      await RisingEdge(self.dut.core_clk)
      self.current_cycle += 1
      for ns in range(self.nodeslot_count):
        signal_name = f'nodeslot_state[{ns}]'
        current_state = getattr(self.dut, signal_name).value

        if current_state != self.previous_states[signal_name]:
          cycle_diff = self.current_cycle - self.last_change_cycle[signal_name]
          prev_state = self.previous_states[signal_name]
         
          prev_state_name = self.states[prev_state]
        
          self.state_cycle_dict[signal_name][prev_state_name].append(cycle_diff)

          self.last_change_cycle[signal_name] = self.current_cycle
          self.previous_states[signal_name] = current_state



  def get_cycle_profile(self):
      non_empty_nodes = {k: v for k, v in self.state_cycle_dict.items() if any(len(cycles) > 0 for cycles in v.values())}

      state_means = {state: [] for state in self.states}
      
      for state in self.states:
          state_values = []
          for node, cycles in non_empty_nodes.items():
              if state in cycles and cycles[state]:
                  state_values.extend(cycles[state])
          if state_values:
              state_means[state] = mean(state_values)
          else:
              state_means[state] = 0

      return state_means
