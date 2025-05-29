print("First number?")
N1 = io.read()
print("Second number?")
N2 = io.read()
print("Operation?")
Operand = io.read()

M = {}

function M.add(n1, n2)
	print(n1 + n2)
end

function M.sub(n1, n2)
	print(n1 - n2)
end

function M.mul(n1, n2)
	print(n1 * n2)
end

function M.fract(n1, n2)
	print(n1 / n2)
end

function M.convert(n1, n2)
	if type(n1) == "string" then
		n1 = tonumber(n1)
	end
	if type(n2) == "string" then
		n2 = tonumber(n2)
	end

	return n1, n2
end

N1, N2 = M.convert(N1, N2)

if Operand == "+" then
	M.add(N1, N2)
elseif Operand == "-" then
	M.sub(N1, N2)
elseif Operand == "*" then
	M.mul(N1, N2)
elseif Operand == "/" then
	M.fract(N1, N2)
else
	print("The operand was not valid")
end
