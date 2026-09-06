import gymnasium as gym

from . import agents


gym.register(
    id="Template-2foot-Direct-v0",
    entry_point=f"{__name__}.2foot_env:2footEnv",
    disable_env_checker=True,
    kwargs={
        "env_cfg_entry_point": f"{__name__}.2foot_env_cfg:2footEnvCfg",
        "rsl_rl_cfg_entry_point": f"{agents.__name__}.rsl_rl_ppo_cfg:2footPPORunnerCfg",
    },
)
