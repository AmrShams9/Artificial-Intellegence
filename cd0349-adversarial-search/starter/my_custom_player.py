from sample_players import DataPlayer
import random
from isolation import DebugState

class CustomPlayer(DataPlayer):
    """
    Implement your own agent to play Knight's Isolation.

    The get_action() method is the only required method for this project.
    You can modify the interface for get_action by adding named parameters
    with default values, but the function MUST remain compatible with the
    default interface.

    NOTES:
    - The test cases will NOT be run on a machine with GPU access, nor be
      suitable for using any other machine learning techniques.

    - You can pass state forward to your agent on the next turn by assigning
      any pickleable object to the self.context attribute.
    """
    
    def get_action(self, state):
        """
        Employ an adversarial search technique to choose an action
        available in the current state. Call self.queue.put(ACTION) at least
        once.

        This method must call self.queue.put(ACTION) at least once, and may
        call it as many times as you want; the caller will be responsible
        for cutting off the function after the search time limit has expired.

        See RandomPlayer and GreedyPlayer in sample_players for more examples.
        """
        depth = 1
        while True:
            # Call the principal_variation_search function to get the best move
            self.queue.put(self.principal_variation_search(state, depth))
            depth += 1
        print('In get_action(), state received:')
        debug_board = DebugState.from_state(state)
        print(debug_board)

    def alpha_beta_search(self, state, depth, alpha, beta, maximizing_player):
        actions = state.actions()
        if actions:
            best_action = actions[0]
        else:
            best_action = None
        for action in actions:
            new_state = state.result(action)
            # Use the _alpha_beta_min_max function to evaluate the move
            value = self._alpha_beta_min_max(new_state, depth - 1, alpha, beta, not maximizing_player)
            if value > alpha:
                alpha = value
                best_action = action
        return best_action

    def _alpha_beta_min_max(self, state, depth, alpha, beta, maximizing_player):
        if state.terminal_test():
            return state.utility(self.player_id)
        if depth <= 0:
            return self.score(state)
        if maximizing_player:
            value = -float('inf')
            for action in state.actions():
                new_state = state.result(action)
                value = max(value, self._alpha_beta_min_max(new_state, depth - 1, alpha, beta, False))
                alpha = max(alpha, value)
                if alpha >= beta:
                    break
            return value
        else:
            value = float('inf')
            for action in state.actions():
                new_state = state.result(action)
                value = min(value, self._alpha_beta_min_max(new_state, depth - 1, alpha, beta, True))
                beta = min(beta, value)
                if alpha >= beta:
                    break
            return value

    def principal_variation_search(self, state, depth):
        alpha = float("-inf")
        beta = float("inf")
        actions = state.actions()
        if actions:
            best_action = actions[0]
        else:
            best_action = None
        maximizing_player = True
        value = -float('inf')
        for i, action in enumerate(actions):
            new_state = state.result(action)
            if i == 0:
                value = max(value, self._pvs_min_max(new_state, depth - 1, alpha, beta, maximizing_player))
            else:
                value = max(value, self._pvs_min_max(new_state, depth - 1, alpha, alpha + 1, maximizing_player))
                if value > alpha:
                    value = max(value, self._pvs_min_max(new_state, depth - 1, alpha, beta, maximizing_player))
            if value > alpha:
                alpha = value
                best_action = action
        return best_action

    def _pvs_min_max(self, state, depth, alpha, beta, maximizing_player):
        if state.terminal_test():
            return state.utility(self.player_id)
        if depth <= 0:
            return self.score(state)
        if maximizing_player:
            value = -float('inf')
            for i, action in enumerate(state.actions()):
                new_state = state.result(action)
                if i == 0:
                    value = max(value, self._pvs_min_max(new_state, depth - 1, alpha, beta, False))
                else:
                    value = max(value, self._pvs_min_max(new_state, depth - 1, alpha, alpha + 1, False))
                    if value > alpha:
                        value = max(value, self._pvs_min_max(new_state, depth - 1, alpha, beta, False))
                alpha = max(alpha, value)
                if alpha >= beta:
                    break
            return value
        else:
            value = float('inf')
            for i, action in enumerate(state.actions()):
                new_state = state.result(action)
                if i == 0:
                    value = min(value, self._pvs_min_max(new_state, depth - 1, alpha, beta, True))
                else:
                    value = min(value, self._pvs_min_max(new_state, depth - 1, beta - 1, beta, True))
                    if value < beta:
                        value = min(value, self._pvs_min_max(new_state, depth - 1, alpha, beta, True))
                beta = min(beta, value)
                if alpha >= beta:
                    break
            return value

    def score(self, state):
        self_location = state.locs[self.player_id]
        opponent_location = state.locs[1 - self.player_id]
        self_liberties = state.liberties(self_location)
        opponent_liberties = state.liberties(opponent_location)
        return len(self_liberties) - len(opponent_liberties)
