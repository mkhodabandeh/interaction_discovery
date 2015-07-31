
data = rand(100, 10);
labels = ceil(5 * rand(100, 1));

options = ['-s 4 -B 10 -c ', num2str(1)];
svmmodel = train(labels, sparse(data), options);
