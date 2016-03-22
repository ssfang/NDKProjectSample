#include <stddef.h>
#include <stdio.h>

template<class T, const size_t N>
class Array {
private:
	T arr[N];
public:
	T *data() {
		return arr;
	}

	const T *data() const {
		return arr;
	}

	T *end() {
		return arr + N;
	}

	const T *end() const {
		return arr + N;
	}

	T &operator[](ptrdiff_t i) {
		return arr[i];
	}
	const T &operator[](ptrdiff_t i) const {
		return arr[i];
	}

	const size_t size() const {
		return N;
	}
};

int main(int argc, const char *argv[])
{
    Array<char, 2> v2;
    for (size_t i = 0; i < v2.size(); ++i) {
        v2[i] = 65 + i;
    }

    printf("Array<char, %zu> = %.*s\n", v2.size(), v2.size(), v2.data());

    printf("Hello World\n");
    return 0;
}
