def run(self):
    for episode in range(episodes):

        self.buffer.reset()
        self.envs.reset()

        # Rollout
        for step in range(self.episode_length):
            # Sample actions
            values, actions, action_log_probs = self.collect(step)
            # Obser reward and next obs
            obs, share_obs, rewards, dones = self.envs.step(actions)

            self.buffer.insert(obs, share_obs, rewards, dones, values, actions, action_log_probs)

        self.compute_return()
        self.update_network()