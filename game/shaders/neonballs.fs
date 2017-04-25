#define MAX_CIRCLES 100
#define BASE_RADIUS 5.0
const float[NUM_CIRCLES] radii = float[](10.0, 17.0, 25.0);
const vec2[NUM_CIRCLES] centers = vec2[](vec2(200, 400), vec2(500, 400), vec2(800, 400));
#define SEGMENTS 10
#define PI 3.141592
const float intensity = 0.7;
const vec3[NUM_CIRCLES] colors = vec3[](vec3(1.0, 1.0, 0.0), vec3(0.0, 1.0, 1.0), vec3(1.0, 0.0, 1.0));

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 final_color = vec3(0.0);
    for (int n = 0; n < NUM_CIRCLES; n++) {
        vec2 center = centers[n];
        float radius_mult = radii[n];
        int num_segments = SEGMENTS * int(radius_mult);
        float radius = radius_mult * BASE_RADIUS;
        vec3 color = colors[n];
        float field = 0.0;
        for (int i = 0; i < num_segments; i++) {
            float angle = float(i) * 2.0 * 3.141592 / float(num_segments);
            vec2 point = center + radius * vec2(cos(angle),sin(angle));
            float dis = distance(fragCoord, point);

            field += (1.0)/(dis*dis);
        }
        
        final_color += color * field;
    }
	fragColor = vec4(final_color, 1.0);
}
