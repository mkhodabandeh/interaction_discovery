# Interaction Discovery
## Discovering Human Interactions in Videos with Limited Data Labeling


Please run the following commands in Matlab.
```
>> startup
>> run_algorithm()
```

Settings of the algorithm should be set in the file `run_algorithm.m`
All the settings are explained in the comments.

In order to run the code you need to extract features from your data.
The data that we used for the Collective Activity dataset is available 
and can be found here: `./data/collective_activity.mat`

Basically the functions that you need to reimplement for your own purpose
are:

1- `read_data.m`
<dd>
        This function will be called during the code to read the data. You
        should first extract your features and save them in a file. Then 
        write a code in read_data.m that reads the file and sets the 
        required variables. For instance take a look at the codes related
        to collective activity. Lines 332 to 341.
</dd>

2- `eval.m`

        This function evaluates the results of the algorithm. Please take 
        a look at the file:
        `eval_lmmca_with_global_group_activity_user_interaction.m`

3- `grad.m`

        This function calculates the gradiant of the objective function. 
        The implementation of this function depends on your model.
        Please take a look at the file:
        `grad_lmmca_with_global_group_activity_user_interaction.m`

4- `inference.m`

        This function does the inference of latent variables and the 
        implementation depends on the model.
        Please take a look at the file:
        `infer_global_latent_variables_group_activity.m`

5- After implementing the mentioned functions you need to manualy set some
    variables that tells the algorithm to use your functions.
    Please take a look at the lines 111 to 125 of `main_mmca.m`
