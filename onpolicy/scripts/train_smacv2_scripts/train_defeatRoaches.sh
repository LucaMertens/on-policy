# env="StarCraft2v2"
env="SMACv2"
map="DefeatRoaches"
algo="mappo"
units="5v5" # 5 marines vs 5 roaches

exp="defeatroaches"
seed_max=1


echo "env is ${env}, map is ${map}, algo is ${algo}, exp is ${exp}, max seed is ${seed_max}"
for seed in `seq ${seed_max}`;
do
    echo "seed is ${seed}:"
    CUDA_VISIBLE_DEVICES=0 python ../train/train_smac.py \
        --env_name ${env} \
        --algorithm_name ${algo} \
        --experiment_name ${exp} \
        --map_name ${map} \
        --seed ${seed} \
        --units ${units} \
        --n_training_threads 1 \
        --n_rollout_threads 1 \
        --num_mini_batch 1 \
        --use_render \
        --save-gifs \
        --episode_length 400 \
        --num_env_steps 1 \
        --ppo_epoch 5 \
        --use_value_active_masks \
        --n_render_rollout_thread 1 \
        --user_name "luca-mertens-kiel-university" # wandb user name
        # --use_eval \
        # --eval_episodes 32
done
