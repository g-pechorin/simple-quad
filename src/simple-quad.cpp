/***
 * Stoopid-Quad buffered example with GLFW3
 * Based on this ; http://www.glfw.org/docs/latest/quick.html#quick_example
 */
#include <GLFW/glfw3.h>

#include <iostream>

int main(int argc, char* argv[])
{

	glfwSetErrorCallback([](int error, const char* description)
	{
		std::cerr << "ERROR " << std::hex << error << std::dec << " ; " << description << std::endl;
	});

	if (!glfwInit())
	{
		std::cerr << "ERROR ; glfwInit() failed" << std::endl;
		exit(EXIT_FAILURE);
	}

	glfwWindowHint(GLFW_STEREO, true);

	GLFWwindow* window = glfwCreateWindow(640, 480, "Stoopid-Quad Buffered", nullptr, nullptr);
	if (!window)
	{
		std::cerr << "ERROR ; glfwCreateWindow(...) failed" << std::endl;
		glfwTerminate();
		exit(EXIT_FAILURE);
	}
	glfwMakeContextCurrent(window);
	//glfwSwapInterval(1);

	glfwSetKeyCallback(window, [](GLFWwindow* window, int key, int scancode, int action, int mods)
	{
		if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
			glfwSetWindowShouldClose(window, GL_TRUE);
	});

	while (!glfwWindowShouldClose(window))
	{
		float ratio;
		int width, height;
		glfwGetFramebufferSize(window, &width, &height);
		ratio = width / (float)height;
		glViewport(0, 0, width, height);

		const float spin = (float)glfwGetTime() * 50.f;

		bool left = true;
		do
		{
			// switch to the eye
			glDrawBuffer(left ? GL_BACK_LEFT : GL_BACK_RIGHT);
			glClear(GL_COLOR_BUFFER_BIT);

			// setup the view-projection matricies
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glOrtho(-ratio, ratio, -1.f, 1.f, 1.f, -1.f);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			glRotatef(left ? -spin : spin, 0.f, 0.f, 1.f);

			// draw the thing
			glBegin(GL_TRIANGLES);
			{
				glColor3f(1.f, 0.f, 0.f);
				glVertex3f(-0.6f, -0.4f, 0.f);

				glColor3f(0.f, 1.f, 0.f);
				glVertex3f(0.6f, -0.4f, 0.f);

				glColor3f(0.f, 0.f, 1.f);
				glVertex3f(0.f, 0.6f, 0.f);
			}
			glEnd();

			// draw the side thingies
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			glBegin(GL_QUADS);
			if (left)
			{
				glColor3f(1.f, 0.f, 0.f);
				glVertex3f(-0.9f, +1, 0.f);
				glVertex3f(-0.9f, -1, 0.f);
				glVertex3f(-0.8f, -1, 0.f);
				glVertex3f(-0.8f, +1, 0.f);
			}
			else
			{
				glColor3f(0.f, 0.f, 1.f);
				glVertex3f(+0.8f, -1, 0.f);
				glVertex3f(+0.8f, +1, 0.f);
				glVertex3f(+0.9f, +1, 0.f);
				glVertex3f(+0.9f, -1, 0.f);
			}
			glEnd();
			// switch eyes
			left = !left;

			// if we get here and left is now true ; we've just finished the right eye and we can stop
		} while (false == left);
		
		glfwSwapBuffers(window);
		glfwPollEvents();
	}
	glfwDestroyWindow(window);
	glfwTerminate();

	return EXIT_SUCCESS;
}
