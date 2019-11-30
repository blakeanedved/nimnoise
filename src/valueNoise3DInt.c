long valueNoise3DInt(int x, int y, int z, int seed){
    long result = (x + y + z + seed) & 0x7fffffff;
    result = (result >> 13) ^ result;
    return ((result * (result * result * 60493 + 19990303) + 1376312589) & 0x7fffffff);
}