$env_name = "StarCraft2v2"
$map = "DefeatRoaches"
$algo = "mappo"
$units = "5v5" # 5 marines vs 5 roaches

$exp = "defeatroaches"

Write-Host "env is $env_name, map is $map, algo is $algo, exp is $exp"

    
$env:CUDA_VISIBLE_DEVICES = "0"
    
python ../train/train_smac.py `
    --env_name $env_name `
    --algorithm_name $algo `
    --experiment_name $exp `
    --map_name $map `
    # --seed $seed `
    --units $units `
    --n_training_threads 1 `
    --n_rollout_threads 8 `
    --num_mini_batch 1 `
    --episode_length 400 `
    --num_env_steps 20000000 `
    --ppo_epoch 5 `
    --use_value_active_masks
    # --use_eval `
    # --eval_episodes 32
}